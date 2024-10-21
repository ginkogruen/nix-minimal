{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.custom.neovim.nixvim;
in {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../common-modules/nixvim/nixvim-common.nix
  ];

  options.custom = {
    # Options should be declared in nixvim-common.nix
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      defaultEditor = true;
      vimdiffAlias = true;
    };
  };
}
# documentation & notes
# plugins needed: 'sophacles/vim-processing', 'davidgranstrom/scnvim', 'edkolev/tmuxline.vim'
# plugins installed: 'nvim-lualine/lualine.nvim', 'lervag/vimtex'
# Configure neovide options

