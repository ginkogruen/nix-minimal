{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.custom.shell.zoxide;
in {
  options = {
    custom.shell.zoxide.enable = mkEnableOption "Enable zoxide systemwide integration";
    custom.shell.zoxide.enableFishIntegration = mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Whether to enable Fish integration.
      '';
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [zoxide];

    # Enable fish shell integration
    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
      ${pkgs.zoxide}/bin/zoxide init fish | source
    '';
  };
}
