{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    #./hardware-configuration.nix # Include the results of the hardware scan.
    ./disko.nix # disko disk partition config

    ../../nixos-modules/imports.nix
  ];

  custom = {
    services = {
      tailscale.enable = true;
      openssh.enable = true;
      syncthing = {
        enable = true;
        user = "ginkogruen";
        dataDir = "/home/ginkogruen";
      };
    };

    disko = {
      enable = true;
      mainDisk = "/dev/nvme0n1";
      useEncryption = true;
    };
    impermanence.enable = true;
    nixos-facter.enable = true;
    sops-nix.enable = true;
  };

  # network manager fix
  systemd = {
    services.NetworkManager-wait-online.enable = lib.mkForce false;
    services.systemd-networkd-wait-online.enable = lib.mkForce false;
    network = {
      enable = true;
      networks."10-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "yes";
      };
    };
  };

  services = {
    xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
  };

  # NOTE: NOT IN .NIXFILES
  # Set the locale
  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {LC_MONETARY = "de_DE.UTF-8";};
    supportedLocales = ["all"];
  };

  # Enable nix-command and flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot = {
    initrd.systemd.enable = true;
    kernel.sysctl = {
      "kernel.sysrq" = 1;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true; # Make /tmp work stateless
    supportedFilesystems = ["zfs"];
    kernelParams = ["nohibernate"]; # Needed for ZFS
  };

  environment.systemPackages = with pkgs; [
    zfs # TODO Is this needed?
    git
    gh
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  networking = {
    useNetworkd = true;
    hostName = "enceladus";
    hostId = "0cad2592"; # needed for ZFS
    firewall = {
      enable = true; # Open ports in the firewall
      #allowedTCPPorts = [ ... ];
      #allowedUDPPorts = [ ... ];
    };
  };

  security.polkit.enable = true; # Enable normal user to do 'reboot' among others.

  users = {
    mutableUsers = false; # Declarative users only
    users = {
      root = {
        #initialPassword = "password";
        hashedPasswordFile = config.sops.secrets."password/user/root".path;
      };
      ginkogruen = {
        isNormalUser = true;
        createHome = true;
        #initialPassword = "password";
        hashedPasswordFile = config.sops.secrets."password/user/ginkogruen".path;
        extraGroups = ["networkmanager" "wheel"];
      };
    };
  };

  system.stateVersion = "24.05"; # You know the deal.
}
