{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  options.custom = {
    impermanence.enable = lib.mkEnableOption "Enable hm-impermanence";
  };
  config = {
    home.persistence."/persist/home/ginkogruen" = {
      directories = [
        "Downloads"
        ".local/state/nix/profiles" # Probable fix for home-manager service not starting
	".nixfiles"
      ];
      files = [
        ".ssh/id_ed25519"
        ".ssh/id_ed25519.pub"
	".config/sops/age/keys.txt"
      ];
      allowOther = true; # Needs 'programs.fuse.userAllowOther = true;'
    };
  };
}
