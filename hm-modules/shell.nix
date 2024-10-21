# shell.nix
# Settings for shells (fish & zsh) and basic command line programs
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.shell;
in {
  options.custom = {
    shell.enable = mkEnableOption "Enable shell hm-module";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {vide = "neovide";};
      zplug = {
        enable = true;
        plugins = [
          {name = "jeffreytse/zsh-vi-mode";}
        ];
      };
    };

    programs.fish = {
      enable = true;
      shellAliases = {
        vide = "neovide";
        cat = "bat";
      };
      shellInit = ''
        # setup vi-mode
        fish_vi_key_bindings
        fish_vi_cursor
      '';
    };
  };
}
