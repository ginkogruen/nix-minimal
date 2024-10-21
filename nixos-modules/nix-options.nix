{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.nix-options;
in {
  options.custom = {
    nix-options.enable = mkEnableOption "Enable nix-options nixos-modules";
  };
  config = mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        builders-use-substitutes = true;
        trusted-users = ["ginkogruen" "root" "@wheel"];
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
      # Include github token to avoid getting rate-limited via 'access-tokens' option.
      extraOptions = ''
        !include ${config.sops.secrets.github-token.path}
      '';
      gc = {
        automatic = true; # disabled due to using nh
        dates = "daily";
        options = "--delete-older-than 14d";
      };
    };
  };
}
