{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.neovim.nixvim; # Option naming to mirror module location
in {
  options.custom = {
    neovim.nixvim.enable = mkEnableOption "Enable nixvim module";
  };
  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      #defaultEditor = true; # hm-manager specific!
      viAlias = true;
      vimAlias = true;
      #vimdiffAlias = true; # hm-manager specific!
      colorschemes.nord = {
        enable = true;
      };
      opts = {
        number = true;
        termguicolors = true;
        guifont =
          if pkgs.stdenv.isLinux
          then "Iosevka:h10"
          else if pkgs.stdenv.isDarwin
          then "Iosevka:h13"
          else "";
      };
      plugins = {
        lualine = {
          enable = true;
          settings = {
            options = {
              globalstatus = true;
              theme = "nord";
            };
          };
        };
        indent-blankline.enable = true;
        treesitter = {
          enable = true;
          nixGrammars = true;
          nixvimInjections = true;
        };
        openscad.enable = true;
        orgmode.enable = true;
        vimtex = {
          enable = true;
          settings = {
            view_method = "zathura";
          };
        };
        lsp-format.enable = true;
        lsp = {
          enable = true;
          servers = {
            clojure_lsp.enable = true; # Clojure
            texlab.enable = true; # LaTeX
            ts_ls.enable = true; # Typescript / Javascript
            eslint.enable = true; # TS / JS Linter
            hls = {
	      enable = true; # Haskell
	      installGhc = true;
	    };
            typos_lsp = {
              # Typos
              enable = true;
              extraOptions.init_options.diagnosticSeverity = "Hint";
            };
            nil_ls.enable = true; # Nix
            bashls.enable = true; # Bash
            jdtls.enable = true; # Java
            lua_ls = {
              # Lua
              enable = true;
              settings.telemetry.enable = false;
            };
            pyright.enable = true; # Python
            r_language_server = {
	      enable = true;
	      package = null;
	    };
            rust_analyzer = {
              # Rust
              enable = true;
              installRustc = true;
              installCargo = true;
            };
            openscad_lsp.enable = true; # OpenSCAD
	    yamlls.enable = true; # YAML
	    jsonls.enable = true; # JSON
          };
        };
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            mapping = {
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
            };
            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
            ];
          };
        };
        none-ls = {
          enable = true;
          sources = {
            code_actions = {
              statix.enable = true;
            };
            diagnostics = {
              fish.enable = true;
              markdownlint.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };
            formatting = {
              #prettier.enable = true; # possible conflict with 'ts-ls'.
              alejandra.enable = true;
            };
          };
        };
        cmp-git.enable = false;
        commentary.enable = true;
      };
      extraPlugins = [pkgs.vimPlugins.scnvim];
    };
  };
}
