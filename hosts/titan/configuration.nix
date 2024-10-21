/*
===enceladus configuration===
*/
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./disk-config.nix # disko disk partition config

    ../../nixos-modules/imports.nix # modules unique to nixos
  ];

  /*
  ===custom module options===
  */

  custom = {
    profiles = {
      shell.profile = "default";
    };

    services = {
      tailscale.enable = true;
      openssh.enable = true;
    };

    console.enable = true;
    impermanence.enable = true;
    localisation.enable = true;
    nh.enable = true;
    nix-options.enable = true;
    sops-nix.enable = true;
  };

  /*
  ===normal config===
  */

  # network manager fix
  systemd = {
    services.NetworkManager-wait-online.enable = lib.mkForce false;
    services.systemd-networkd-wait-online.enable = lib.mkForce false;
  };

  # Configure keymap in X11 # wm?
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  boot = {
    kernel.sysctl = {
      "kernel.sysrq" = 1; # Enable Magic SysRq key
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["ntfs" "zfs"];
    kernelParams = ["nohibernate"]; # Needed for ZFS
  };

  environment.systemPackages = with pkgs; [
    zfs # TODO Create separate ZFS module
    btop
    curl
    gh
    git
    unzip
    vifm
    zip
    tmux
    fastfetch
    onefetch
    ncdu
    tree
  ];


  #boot.initrd.kernelModules = ["amdgpu"]; # TITAN SPEC.: non amdgpu

  # Start polkit-gnome
  /*
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  */

  networking = {
    useNetworkd = true; # Translate settings to networkd
    networkmanager.enable = true;
    hostName = "titan";
    hostId = "0cad2592"; # needed for ZFS
    interfaces.eno1.wakeOnLan = {
      enable = true;
      policy = ["magic"];
    };
    firewall = {
      enable = true; # Open ports in the firewall
      allowedTCPPorts = [9999];
      #allowedUDPPorts = [ ... ];
    };
  };

  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  environment.variables.EDITOR = "nvim";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ginkogruen = {
    isNormalUser = true;
    description = "ginkogruen";
    createHome = true;
    extraGroups = ["networkmanager" "wheel" "audio" "gamemode"];
    packages = with pkgs; [];
  };

  security.polkit.enable = true;

  # Enable pam for hyprlock
  #security.pam.services.hyprlock = true; # doesn't work

  # List of programs that should be enabled:

  system.stateVersion = "24.05"; # You know the deal.
}
