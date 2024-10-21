# kitty.nix
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.kitty;
in {
  options = {
    custom.kitty.enable = mkEnableOption "Enable kitty hm-module";
  };
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.name = "Iosevka";
      font.size = 11;
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
      themeFile = "Nord";
      settings = {
        # there are settings for fonts available too

        # Mouse
        show_hyperlink_targets = "yes";
        paste_actions = "quote-urls-at-prompt,confirm,confirm-if-large";

        # Performance tuning
        repaint_delay = 5;

        # Terminal bell
        enable_audio_bell = "yes";
        windows_alert_on_bell = "yes";
        #bell_path = /path/to/wav/sound.wav;
        #linux_bell_theme = "__custom"; Not sure how to use this but I would like to create my own sound theme sometime

        # Tab bar
        tab_bar_margin_height = "0.0 0.0";
        tab_bar_style = "powerline";
        tab_powerline_style = "angled";

        # Color scheme
        background_opacity = "1.0";
        background_blur = 64;

        # Advanced
        shell = ".";
        editor = ".";
        allow_remote_control = "no";
        notify_on_cmd_finish = "invisible 30";
      };
    };
  };
}
