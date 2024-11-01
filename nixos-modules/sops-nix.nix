{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.sops-nix;
  hostname = config.networking.hostName;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options = {
    custom.sops-nix.enable = mkEnableOption "enable sops-nix nixos-module";
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";
      validateSopsFiles = false;

      age = {
        sshKeyPaths =
          if config.custom.impermanence.enable
          then ["/persist/etc/ssh/ssh_host_ed25519_key"]
          else ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile =
          if config.custom.impermanence.enable
          then "/persist/var/lib/sops-nix/key.txt" # For impermanence the key need to be in '/persist'
          else "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      secrets = {
        "ssh/host/${hostname}/initrd" = {};
        "ssh/host/${hostname}/ed25519" = {};
        "password/user/ginkogruen".neededForUsers = true;
        "password/user/root".neededForUsers = true;
        "application/tailscale" = {};
        "application/syncthing/${hostname}/cert.pem" = {};
        "application/syncthing/${hostname}/key.pem" = {};
      };
    };

    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
    ];
  };
}
