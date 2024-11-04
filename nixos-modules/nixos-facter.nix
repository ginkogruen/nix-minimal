{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.nixos-facter;
in {
  imports = [inputs.nixos-facter-modules.nixosModules.facter];

  options.custom = {
    facter.enable = mkEnableOption "Enable nixos-facter";
  };

  config = mkIf cfg.enable {
    facter.reportPath = ../hosts/${config.networking.hostName}/facter.json;

    # Get a hardware report by running:
    # $ nix --extra-experimental-features "flakes nix-command" run github:numtide/nixos-facter > facter.json

    # sudo nix run \
    # --option experimental-features "nix-command flakes" \
    # --option extra-substituters https://numtide.cachix.org \
    # --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
    # github:numtide/nixos-facter -- -o facter.json
  };
}
