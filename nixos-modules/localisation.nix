{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.localisation;
in {
  options = {
    custom.localisation.enable = mkEnableOption "Enable localisation nixos-module";
  };
  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_DK.UTF-8";
      supportedLocales = ["all"];
    };

    i18n.extraLocaleSettings = {
      #LC_ADDRESS = "de_DE.UTF-8";
      #LC_IDENTIFICATION = "de_DE.UTF-8";
      #LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      #LC_NAME = "de_DE.UTF-8";
      #LC_NUMERIC = "de_DE.UTF-8";
      #LC_PAPER = "de_DE.UTF-8";
      #LC_TELEPHONE = "de_DE.UTF-8";
      #LC_TIME = "de_DE.UTF-8";
    };
  };
}
