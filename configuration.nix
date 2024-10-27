{
  config,
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
      keyFile = "/persist/var/lib/sops-nix/key.txt"; # Needs to be in persist if using impermanence
      generateKey = true;
    };

    secrets = {
      "users/ginkogruen-pw".neededForUsers = true;
      "users/root-pw".neededForUsers = true;
    };
  };

  # NixOS configuration

  /*
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

  boot.initrd.systemd.enable = true; # Will this fix my issues with booting

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

  users = {
    mutableUsers = false; # Declarative users only
    users = {
      root = {
        #initialPassword = "password";
        hashedPasswordFile = config.sops.secrets."users/root-pw".path;
      };
      ginkogruen = {
        isNormalUser = true;
        createHome = true;
        #initialPassword = "password";
        hashedPasswordFile = config.sops.secrets."users/ginkogruen-pw".path;
        extraGroups = ["networkmanager" "wheel"];
      };
    };
  };

  system.stateVersion = "24.05"; # You know the deal.
}
