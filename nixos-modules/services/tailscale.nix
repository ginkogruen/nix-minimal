{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.services.tailscale;
in {
  options = {
    custom.services.tailscale.enable = mkEnableOption "Enable tailscale service";
  };
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale-auth-key";
    };
  };
}
