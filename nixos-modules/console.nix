# configurations for the console/tty
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.console;
in {
  options = {
    custom.console.enable = mkEnableOption "Enable console nixos-module";
  };

  config = mkIf cfg.enable {
    console = {
      useXkbConfig = true;
      font = "ter-v16b";
      earlySetup = true;
      packages = with pkgs; [terminus_font];
      colors = [
        "2e3440" # nord0
        "bf616a" # nord11
        "a3be8c" # nord14
        "ebcb8b" # nord13
        "81a1c1" # nord9
        "b48ead" # nord15
        "88c0d0" # nord8
        "eceff4" # nord6
        "2e3440" # nord0
        "bf616a" # nord11
        "a3be8c" # nord14
        "ebcb8b" # nord13
        "81a1c1" # nord9
        "b48ead" # nord15
        "88c0d0" # nord8
        "eceff4" # nord6
      ];
    };
  };
}
