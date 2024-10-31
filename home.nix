{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  # Impermanence config (home-manager)
  home.persistence."/persist/home/ginkogruen" = {
    directories = [
      "Downloads"
      ".local/state/nix/profiles" # Probable fix for home-manager not starting
    ];
    allowOther = true; # Needs 'programs.fuse.userAllowOther = true;'
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "ginkogruen";
    homeDirectory = "/home/ginkogruen";
    packages = with pkgs; [
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a anew Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manger without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
