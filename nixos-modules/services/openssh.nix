{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.services.openssh;
  hostname = config.networking.hostName;
in {
  options = {
    custom.services.openssh.enable = mkEnableOption "Enable openssh nixos-module";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      startWhenNeeded = true; # Interesting setting for consideration
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        LogLevel = "VERBOSE";
      };
      knownHosts = {
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # Enable ssh-server in initrd for remote unlocking
    # Login via root@network_ip
    boot.initrd = {
      # Find out correct kernel modules with: 'lspci -v | grep -iA8 'network\|ethernet''
      systemd = {
        network = {
          enable = true;
          networks."10-eno1" = {
            matchConfig.Name = "eno1";
            networkConfig.DHCP = "ipv4";
          };
        };
      };
      availableKernelModules = ["r8169"];
      network = {
        enable = true;
	/*
        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBo8xzMm6ra19K1T3MK+avAUaQdQ1ApmSI0DBB2jJHC" # rhea
          ];
          hostKeys = [
            "${config.sops.secrets."ssh/host/${hostname}/initrd".path}"
          ];
        };
	*/
      };
    };

    users.users."ginkogruen".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBo8xzMm6ra19K1T3MK+avAUaQdQ1ApmSI0DBB2jJHC" # ginkogruen@rhea
    ];
    users.users."root".openssh.authorizedKeys.keys = [
    ];
  };
}
