{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.sops-nix;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  options.custom = {
    sops-nix.enable = mkEnableOption "enable sops-nix hm-module";
  };

  config = mkIf cfg.enable {
    sops = {
      #age.keyFile = "/home/user/.age-key.txt"
      defaultSopsFile = ../secrets.yaml;
    };

    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
    ];
  };
}
