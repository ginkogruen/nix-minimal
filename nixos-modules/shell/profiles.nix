# TODO Currently only one profile available. Figure out solution for supporting multiple profiles.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf;
  cfg = config.custom.profiles;
in {
  options.custom = with lib; {
    # set profiles via string
    profiles.shell.profile = mkOption {
      type = types.str;
      example = "default";
    };

    # enable option used to enable modules
    profiles.shell.default.enable = mkEnableOption "Enable global default shell profile";
  };

  config = {
    custom = {
      # set profile option to true depending on string option
      profiles.shell.default.enable = mkIf (cfg.shell.profile == "default") true;

      shell = {
        starship.enable = mkIf cfg.shell.default.enable true;
        zoxide.enable = mkIf cfg.shell.default.enable true;
      };
    };
  };
}
