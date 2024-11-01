{...}: {
  imports = [
    ./impermanence.nix
    ./sops-nix.nix
    ./sops-fix.nix

    ./services/openssh.nix
    ./services/syncthing.nix
    ./services/tailscale.nix
  ];
}
