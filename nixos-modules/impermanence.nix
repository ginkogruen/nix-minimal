{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  options = {
    custom.impermanence.enable = mkEnableOption "Enable NixOS impermanence module";
  };

  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      files = ["/etc/machine-id"];
      directories = [
        "/var/log" # systemd journal
        "/var/lib/nixos" # for persisting user uids and gids
      ];
    };
  };
}
