{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./disk-config.nix # disko disk partition config

    # Import flake inputs
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
  ];

  # Impermanence options
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    files = ["/etc/machine-id"];
    directories = [
      "/var/log" # systemd journal
      "/var/lib/nixos" # for persisting user uids and gids
    ];
  };

  # Sops-Nix options
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml"; # TODO Change to JSON
    validateSopsFiles = false;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
    };
  };

  # NixOS configuration

  # Remote disk unlocking
  boot.initrd = {
    availableKernelModules = ["r8169"];
    network = {
      enable = true;
      udhcpc.enable = true;
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [];
        hostKeys = ["/etc/secrets/initrd/ssh_host_ed25519_key"];
      };
      #postCommands = '''';
    };
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      LogLevel = "VERBOSE";
    };
    knownHosts = {};
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/run/secrets/tailscale-auth-key";
  };

  # Set the locale
  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {LC_MONETARY = "de_DE.UTF-8";};
    supportedLocales = ["all"];
  };

  # Enable nix-command and flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs"];
    kernelParams = ["nohibernate"]; # Needed for ZFS
  };

  environment.systemPackages = with pkgs; [
    zfs # TODO Is this needed?

    # sops-nix packages # TODO Re-evaluate necessity of permanent install
    age
    sops
    ssh-to-age
  ];

  networking = {
    useNetworkd = true; # Translate settings to networkd
    networkmanager.enable = true;
    hostName = "titan";
    hostId = "0cad2592"; # needed for ZFS
    firewall = {
      enable = true; # Open ports in the firewall
      #allowedTCPPorts = [ ... ];
      #allowedUDPPorts = [ ... ];
    };
  };

  # Declarative users only
  users.mutableUsers = false;

  # User account definition
  users.users.ginkogruen = {
    createHome = true;
    description = "ginkogruen";
    extraGroups = ["networkmanager" "wheel"];
    # TODO Replace hashedPassword by password managed via sops-nix
    hashedPassword = "$y$j9T$i1ERvOjhZbWaKF/9iE6Sx.$JAfRtqcImKIpcUGe.8SPGs25KwYVOtpm.Yr0cSzQ6n5"; # 'initpw'
    isNormalUser = true;
  };

  system.stateVersion = "24.05"; # You know the deal.
}
