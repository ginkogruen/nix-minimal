# git.nix
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.git;
in {
  options = {
    custom.git.enable = mkEnableOption "Enable git hm-module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gh
      git
    ];

    programs.git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
