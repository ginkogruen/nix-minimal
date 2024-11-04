# nix-minimal

Minimal opinionated NixOS configuration for prototyping a base for my personal systems.

The goal is to orchestrate deeply integrated services to play nice with each other.
Most prominently disk configuration which can't be easily changed later on.

Set up should work with minimal user interaction providing a system that works
out of the box and is fully configured.

## Installation guide

For installing this config use nixos anywhere

While nixos-anywhere can be installed through different ways
I'd like to install from the NixOS installer.

To do this boot the installer and set a password via:

```bash
passwd "password"
```

Then find out the ip address to reach your target machine with:

```bash
ip addr
```

And finally install with nixos-anywhere using the following command:

```bash
nix run github:nix-community/nixos-anywhere -- --flake '.#titan' nixos@<ip-address>
```

Note:
If you are on a non x86_64-linux system specify additionally `--build-on-remote`.

Specify disk encryption keys using `--disk-encryption-keys /tmp/secret.key <path-to-local-keyfile>`.

**TODO: Add documentation for passing additional files with `--extra-files` and `--generate-hardware-config`**

## Unlock via SSH

Currently **deactivated**!

To unlock via SSH connect to the machine with:

```bash
ssh root@<ip-address>
```

Then when connected in initrd enter:

```bash
systemctl default
```

Enter the correct password and you are set.

*Note I don't know if this is the best way to go about this but it does work.*

## Functionality goals

I aim to hit the following functionality goals for my systems:

- [x] Declarative partitioning using [disko](https://github.com/nix-community/disko)
- [x] Systemd-boot as bootloader
- [x] Systemd in initrd
- [x] Network defined using systemd-networkd
- [x] ZFS filesystem
- [ ] Configured ZFS filesystem (scrubbing etc.)
- [x] Full disk encryption with ZFS encryption
- [ ] Encryption unlockable through SSH (**NOTE**: This may not have worked as expected)
- [ ] Tailscale in initrd
- [ ] ~~SWAP partition~~
- [x] Impermanence setup for NixOS
- [x] Impermanence rollback via ZFS snapshot
- [x] Impermanence setup for home-manager
- [ ] Impermanence safety snapshot on shutdown
- [x] Secrets management using [sops-nix](https://github.com/Mic92/sops-nix)
- [ ] Documentation for how things work
- [x] Setup with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [ ] Generate `hardware-configuration.nix` with nixos-anywhere
- [ ] Optional hardware adjustment via [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- [ ] Optional hardware adjustment via [nixos-facter](https://github.com/numtide/nixos-facter)
- [ ] Optional secure boot with [lanzaboote](https://github.com/nix-community/lanzaboote)
- [x] Setup with [home-manager](https://github.com/nix-community/home-manager)
- [ ] 15min apart snapshots on home (via [sanoid](https://github.com/jimsalterjrs/sanoid))
- [ ] Support for TPM

These goals are subject to change.

## Documentation resources & inspiration

- [Graham Christensen - ZFS Datasets for NixOS](https://grahamc.com/blog/nixos-on-zfs/)
- [Graham Christensen - Erase your darlings](https://grahamc.com/blog/erase-your-darlings/)
- [Remote, encrypted ZFS storage server with NixOS](https://mazzo.li/posts/hetzner-zfs.html)
- [ElvishJerricco/stage1-tpm-tailscale](https://github.com/ElvishJerricco/stage1-tpm-tailscale)
