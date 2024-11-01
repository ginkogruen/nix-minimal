{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  # USAGE in your configuration.nix.
  # Update devices to match your hardware.
  # {
  #  imports = [ ./disko-config.nix ];
  #  disko.devices.disk.main.device = "/dev/sda";
  # }
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1"; # TODO move this into configuration.nix
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
          };
        };
      };
    };
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
          encryption = "aes-256-gcm"; # Set up Encryption for pool
          keyformat = "passphrase";
          keylocation = "file:///tmp/secret.key"; # NOTE must be set during initial installation step
        };
        options.ashift = "12";
        postCreateHook = ''
          zfs set keylocation="prompt" $name;
        '';

        datasets = {
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "/home";
              # Used by services.zfs.autoSnapshot options.
              "com.sun:auto-snapshot" = "true";
            };
            postCreateHook = "zfs snapshot zroot/local/home@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "/nix";
            };
          };
          "local/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "/persist";
            };
          };
          "local/cache" = {
            type = "zfs_fs";
            mountpoint = "/cache";
            options = {
              mountpoint = "/cache";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "/";
            };
            postCreateHook = "zfs snapshot zroot/local/root@blank";
          };
          "local/tmp" = {
            type = "zfs_fs";
            mountpoint = "/tmp";
            options = {
              mountpoint = "/tmp";
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
}
