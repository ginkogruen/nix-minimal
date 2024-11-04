{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce;
  cfg = config.custom.lanzaboote;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.custom = {
    lanzaboote.enable = mkEnableOption "Enable lanzaboote";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    /*
    Create Keys for SecureBoot with:

    $ sudo sbctl create-keys
    [sudo] password for julian:
    Created Owner UUID 8ec4b2c3-dc7f-4362-b9a3-0cc17e5a34cd
    Creating secure boot keys...✓
    Secure boot keys created!

    Keys created this way are located in /etc/secureboot
    */

    boot.loader.systemd-boot.enable = mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
