{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  options = {
    custom.impermanence.enable = mkEnableOption "Enable NixOS impermanence module";
  };

  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      directories = [
        "/var/log" # systemd journal
        "/var/lib/nixos" # for persisting user uids and gids
      ];
      user.ginkogruen = {
        files = [
	  ".ssh/id_ed25519"
	  ".ssh/id_ed25519.pub"
	];
      };
    };

    # NOTE: Temporary workaround for "/etc/machine-id" being persisted causing issues:
    # REF: https://github.com/nix-community/impermanence/issues/229
    boot.initrd.systemd.suppressedUnits = ["systemd-machine-id-commit.service"];
    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    # Create home directory in '/persist' with appropriate permissions
    # This enables home-manager to work correctly
    systemd.tmpfiles.settings = {
      "persist-ginkogruen-homedir" = {
        "/persist/home/ginkogruen" = {
          d = {
            group = "users";
            user = "ginkogruen";
            mode = "0700";
          };
        };
      };
    };

    programs.fuse.userAllowOther = true; # Allow root to access bind mounts (Needed for hm-impermanence)

    security.sudo.extraConfig = "Defaults lecture=never"; # Keep sudo from lecturing

    # Systemd service doing the rollback on boot
    # Taken from discourse from hexa (co-author lilyinstarlight)
    boot.initrd.systemd.services = {
      rollback = {
        description = "Rollback ZFS datasets to a pristine state";
        wantedBy = ["initrd.target"];
        after = ["zfs-import-zroot.service"];
        before = ["sysroot.mount"];
        path = with pkgs; [zfs];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r zroot/local/root@blank && echo "rollback complete"
        '';
      };
      # Rollback '/home'
      rollback-home = {
        description = "Rollback home directory to a pristine state";
        wantedBy = ["initrd.target"];
        after = ["zfs-import-zroot.service"];
        before = ["sysroot.mount"];
        path = with pkgs; [zfs];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r zroot/local/home@blank && echo "rollback complete"
        '';
      };
    };
  };
}
