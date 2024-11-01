{...}: {
  imports = [
    ./impermanence.nix
    ./sops-nix.nix

    ./services/openssh.nix
    ./services/syncthing.nix
    ./services/tailscale.nix
  ];
}
