{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.custom.disko;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.custom.disko = {
    enable = mkEnableOption "Enable declarative disk partitioning with disko";
    useTmpfs = mkEnableOption "Use tmpfs instead of the default ZFS for '/' and '/home'.";
    useLegacyMountpoints = mkEnableOption "Set ZFS mountpoints to legacy";
    useEncryption = mkEnableOption "Enable ZFS native encryption";
    mainDisk = mkOption {
      example = "/dev/nvme0n1";
      description = "Sets the 'disko.devices.disk.main.device' option of disko";
      type = with types; uniq str;
    };
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.mainDisk;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
	      swap = {
	        size = "16G";
		content = {
		  type = "swap";
		  discardPolicy = "both";
		  resumeDevice = true;
		};
	      };
            };
          };
        };
      };
      # tmpfs set up
      nodev = {
        "/" = mkIf cfg.useTmpfs {
          fsType = "tmpfs";
          mountOptions = [
            "size=1G"
          ];
        };
        "/home" = mkIf cfg.useTmpfs {
          fsType = "tmpfs";
          mountOptions = [
            "size=1G"
          ];
        };
      };
      # zpool set up
      zpool = {
        zroot = {
          type = "zpool";
          rootFsOptions = {
            # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
            acltype = "posixacl";
            atime = "off";
            compression = "zstd";
            mountpoint = "none";
            xattr = "sa";
            encryption = mkIf cfg.useEncryption "aes-256-gcm"; # Set up Encryption for pool
            keyformat = mkIf cfg.useEncryption "passphrase";
            keylocation = mkIf cfg.useEncryption "file:///tmp/secret.key"; # NOTE must be set during initial installation step
          };
          options.ashift = "12";
          postCreateHook = mkIf cfg.useEncryption ''
            zfs set keylocation="prompt" $name;
          '';

          datasets = {
            "local" = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "local/root" = mkIf (!cfg.useTmpfs) {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/";
              };
              postCreateHook = "zfs snapshot zroot/local/root@blank";
            };
            "local/home" = mkIf (!cfg.useTmpfs) {
              type = "zfs_fs";
              mountpoint = "/home";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/home";
                # Used by services.zfs.autoSnapshot options.
                "com.sun:auto-snapshot" = "true";
              };
              postCreateHook = "zfs snapshot zroot/local/home@blank";
            };
            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/nix";
              };
            };
            "local/persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/persist";
              };
            };
            "local/cache" = {
              type = "zfs_fs";
              mountpoint = "/cache";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/cache";
              };
            };
            "local/tmp" = {
              type = "zfs_fs";
              mountpoint = "/tmp";
              options = {
                mountpoint =
                  if cfg.useLegacyMountpoints
                  then "legacy"
                  else "/tmp";
                sync = "disabled";
              };
            };
          };
        };
      };
    };

    # Non-Disko Settings

    # https://github.com/nix-community/disko/issues/192
    # Apparently there isn't a disko config option for this setting so the normal fileSystems option is expected to be used.
    # For ZFS native mounts another user recommended setting: 'boot.initrd.systemd.enable = true'. I don't know if this would be better currently
    fileSystems = {
      "/persist".neededForBoot = true;
      "/cache".neededForBoot = true;
      "/home".neededForBoot = true;
      "/".neededForBoot = true;
    };
  };
}
