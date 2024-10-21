{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.services.openssh;
in {
  options = {
    custom.services.openssh.enable = mkEnableOption "Enable openssh nixos-module";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      #banner = "";
      startWhenNeeded = true; # Interesting setting for consideration
      settings = {
        #PrintMotd = true; # Print /etc/motd when a user logs in
        PermitRootLogin = "prohibit-password";
        #PermitRootLogin = "yes";
        PasswordAuthentication = false;
        LogLevel = "VERBOSE";
      };
      knownHosts = {
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
