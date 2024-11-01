{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) str;
  cfg = config.custom.services.syncthing;
  hostname = config.networking.hostName;
in {
  options = {
    custom.services.syncthing = {
      enable = mkEnableOption "enable syncthing service";
      user = mkOption {
        default = "syncthing";
        type = str;
      };
      dataDir = lib.mkOption {
        default = "/var/lib/syncthing";
        type = str;
      };
      configDir = lib.mkOption {
        default = cfg.dataDir + "/.config/syncthing";
        type = str;
      };
    };
  };
  config = mkIf cfg.enable {
    # syncthing service: allows only devices and folders configured through nix by default
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = cfg.user;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;
      overrideFolders = true;
      overrideDevices = true;
      key = "${config.sops.secrets."application/syncthing/${hostname}/key.pem".path}";
      cert = "${config.sops.secrets."application/syncthing/${hostname}/cert.pem".path}";
      settings = {
        options = {
          urAccepted = -1;
          #localAnnounceEnabled = true;
        };
        #folders = {};
        #devices = {};
      };
    };

    # Fix home-manager + impermanence: '~/.config' was owned by root
    # Taken from:
    # https://github.com/Ramblurr/nixcfg/blob/5140a2049ac6dfae528ca60c4ffccbff553d638d/hosts/quine/syncthing.nix#L220
    # Earlier version:
    # https://github.com/nix-community/impermanence/issues/74#issuecomment-1523444207
    systemd.services = {
      "syncthing".after = ["home-manager-ginkogruen.service"];
      "syncthing-init".after = ["home-manager-ginkogruen.service"];
    };
  };
}
