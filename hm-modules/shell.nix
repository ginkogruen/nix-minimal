# shell.nix
# Settings for shells (fish & zsh) and basic command line programs
{
  config,
  pkgs,
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

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableTransience = true;
      settings = {
        add_newline = true;
        scan_timeout = 10;
        palette = "nord";
        palettes.nord = {
          nord0 = "#2e3440";
          nord1 = "#3b4252";
          nord2 = "#434c5e";
          nord3 = "#4c566a";
          nord4 = "#d8dee9";
          nord5 = "#e5e9f0";
          nord6 = "#eceff4";
          nord7 = "#8fbcbb";
          nord8 = "#88c0d0";
          nord9 = "#81a1c1";
          nord10 = "#5e81ac";
          nord11 = "#bf616a";
          nord12 = "#d08770";
          nord13 = "#ebcb8b";
          nord14 = "#ebcb8b";
          nord15 = "#b48ead";
        };
        format = lib.concatStrings [
          #"$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          #"$nix_shell" # █
          "[](bg:#00000000 fg:prev_bg)"
          "$line_break"
          "$character"
        ];
        /*
        username = {
          format = "[[ $user](bg:#2e3440 fg:#81a1c1)";
          disabled = false;
          show_always = false;
        };
        */
        hostname = {
          ssh_only = true;
          ssh_symbol = "@";
          format = "[[ $ssh_symbol$hostname ](bg:nord2 fg:nord4)[](fg:nord2 bg:nord9)](nord2)";
          trim_at = ".";
          disabled = false;
        };
        directory = {
          #style = "bg:nord9 fg:nord1 ";
          format = "[[ $path ](bg:nord9 fg:nord1 bold)](nord9)";
          truncation_length = 3;
          truncation_symbol = "…/";
          truncate_to_repo = false;
        };
        git_branch = {
          symbol = "";
          style = "bg:#81a1c1";
          format = "[[](bg:nord2 fg:prev_bg)[ $branch ](fg:nord4 bg:nord2)](nord2)";
        };
        git_status = {
          style = "bg:#81a1c1";
          format = "[[($all_status$ahead_behind )](fg:nord4 bg:nord2)](nord2)";
        };
      };
    };

    # bat, cat with wings
    programs.bat = {
      enable = true;
      config = {
        theme = "Nord";
      };
    };

    # eza, and alternative for ls
    programs.eza = {
      enable = true;
      git = true;
    };

    # fzf, a command line fuzzy finder
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    # z, a cd alternative
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    # thefuck, command line typo correction
    programs.thefuck = {
      enable = true;
      package = pkgs.thefuck.overridePythonAttrs {doCheck = false;};
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = ''
        set-option -sg escape-time 50
        source-file ~/.config/tmux/tmuxline.conf
      '';
      keyMode = "vi";
      mouse = false;
      plugins = [];
      secureSocket = false;
      #shell = "";
    };
  };
}
