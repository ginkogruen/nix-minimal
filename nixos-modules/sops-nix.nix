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
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      secrets = {
        "data_storage/stash" = {};
        "github-token" = {};
        "nix-store-keys/${config.networking.hostName}/cache-priv-key.pem" = {};
        "nix-store-keys/${config.networking.hostName}/cache-pub-key.pem" = {};
        "restic/environmentFile" = {};
        "restic/passwordFile" = {};
        "restic/repositoryFile" = {};
        "tailscale-auth-key" = {};
        "syncthing/${config.networking.hostName}/cert.pem" = {};
        "syncthing/${config.networking.hostName}/key.pem" = {};
        "paperless-ngx-admin-pw" = {};
      };
    };

    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
    ];
  };
}
