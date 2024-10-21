{...}: {
  imports = [
    # ./
    ./localisation.nix # settings locales
    ./nix-options.nix # nix related: caches, gc & experimental settings
    ./nh.nix # nix helper
    ./console.nix # configuring console settings (color etc.)
    ./impermanence.nix
    ./sops-nix.nix # global sops-nix config

    # ./services
    ./services/openssh.nix # ssh
    ./services/tailscale.nix
  ];
}
