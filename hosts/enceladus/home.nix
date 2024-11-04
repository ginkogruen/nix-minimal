{pkgs, ...}: {
  imports = [
    ../../hm-modules/imports.nix
  ];

  custom = {
    git.enable = true;
    impermanence.enable = true;
    sops-nix.enable = true;
  };

  home = {
    username = "ginkogruen";
    homeDirectory = "/home/ginkogruen";
    packages = with pkgs; [];
  };

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}
