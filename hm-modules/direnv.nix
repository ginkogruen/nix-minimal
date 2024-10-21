{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.direnv;
in {
  options.custom = {
    direnv.enable = mkEnableOption "Enable direnv module";
  };

  config = mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        #enableFishIntegration = true; # Nix threw an error about multiple definition with this configured
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      bash.enable = true;
      fish.enable = true;
      zsh.enable = true;
    };

    /*
    I may need to hook it into my shell as well.
    It did seem to work without anything extra with fish at least.

    From: https://direnv.net/docs/hook.html:

    BASH: Add 'eval "$(direnv hook bash)"' to ~/.bashrc
    ZSH: Add 'eval "$(direnv hook zsh)"' to ~/.zshrc
    FISH: Add 'direnv hook fish | source' to ~/.config/fish/config.fish
    */
  };
}
