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

  # Impermanence config
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    files = ["/etc/machine-id"];
    directories = [
      "/var/log" # systemd journal
      "/var/lib/nixos" # for persisting user uids and gids
    ];
  };

  # Create home directory in /persist with appropriate permissions
  # This enables home-manager to work correctly
  systemd.tmpfiles.settings = {
    "persist-ginkogruen-homedir" = {
      "/persist/home/ginkogruen" = {
        d = {
          group = "users";
          user = "ginkogruen";
          mode = "0700";
        };
      };
    };
  };

  programs.fuse.userAllowOther = true; # Allow root to access bind mounts (impermanence)
  security.sudo.extraConfig = "Defaults lecture=never"; # Keep sudo from lecturing

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
      "private_keys/initrd-host-key" = {};
    };
  };

  # NixOS configuration

  services = {
    # OpenSSH
    openssh = {
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
    tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale-auth-key";
    };

    xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
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

  boot = {
    initrd = {
      systemd = {
        enable = true; # Magic setting do not disable (Fixes ZFS boot order issues)
        network = {
          networks."10-eno1" = {
            matchConfig.Name = "eno1";
            networkConfig.DHCP = "ipv4";
          };
        };
        services = {
          # Systemd service doing the rollback on boot
          # Taken from discourse from hexa (co-author lilyinstarlight)
          rollback = {
            description = "Rollback ZFS datasets to a pristine state";
            wantedBy = ["initrd.target"];
            after = ["zfs-import-zroot.service"];
            before = ["sysroot.mount"];
            path = with pkgs; [zfs];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              zfs rollback -r zroot/local/root@blank && echo "rollback complete"
            '';
          };
          # Rollback /home
          rollback-home = {
            description = "Rollback home directory to a pristine state";
            wantedBy = ["initrd.target"];
            after = ["zfs-import-zroot.service"];
            before = ["sysroot.mount"];
            path = with pkgs; [zfs];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              zfs rollback -r zroot/local/home@blank && echo "rollback complete"
            '';
          };
        };
        # TODO Configure systemd unit for ZFS unlock
      };
      availableKernelModules = ["r8169"];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBo8xzMm6ra19K1T3MK+avAUaQdQ1ApmSI0DBB2jJHC"];
          hostKeys = [
            "${config.sops.secrets."private_keys/initrd-host-key".path}"
          ];
        };
      };
    };
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
