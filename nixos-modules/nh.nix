{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.nh;
in {
  options.custom = {
    nh.enable = mkEnableOption "Enable nh helper module";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = "/home/ginkogruen/.nixfiles";
      clean = {
        enable = false;
        extraArgs = "--keep-since 7d --keep 5";
        dates = "weekly";
      };
    };
  };
}
