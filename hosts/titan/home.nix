{pkgs, ...}: {
  imports = [
    ../../hm-modules/imports.nix
  ];

  /*
  ===custom module options===
  */

  custom = {
    direnv.enable = true;
    git.enable = true;
    shell.enable = true;
    sops-nix.enable = true;
    ssh.enable = true;
  };

  /*
  ===normal config===
  */

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ginkogruen";
  home.homeDirectory = "/home/ginkogruen";

  home.packages = with pkgs; [
  ];

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
