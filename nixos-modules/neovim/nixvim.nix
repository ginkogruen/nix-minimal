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
    inputs.nixvim.nixosModules.nixvim
    ../../common-modules/nixvim/nixvim-common.nix
  ];

  options = {
    # Options should be declared in nixvim-common.nix
  };

  config =
    mkIf cfg.enable {
    };
}

