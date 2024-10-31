# nix-minimal

Minimal opinionated NixOS configuration to be used as a base system to build upon.

The Aim is to provide a structure for all things which have to be done
on install and can't easily be changed later.

It should also be possible to set this up with minimal interaction and effort.

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
- [x] ZFS filesystem
- [x] Full disk encryption with ZFS encryption
- [x] Encryption unlockable through SSH
- [ ] ~~SWAP partition~~
- [x] Impermanence setup for NixOS
- [x] Impermanence rollback via ZFS snapshot
- [x] Impermanence setup for home-manager
- [ ] Impermanence safety snapshot on shutdown
- [ ] Documentation for how things work
- [x] Setup with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [ ] Optional secure boot with [lanzaboote](https://github.com/nix-community/lanzaboote)
- [x] Setup with [home-manager](https://github.com/nix-community/home-manager)

I may not hit every one of these goals so these are subject to change.

## Documentation resources & inspiration

- [Graham Christensen - ZFS Datasets for NixOS](https://grahamc.com/blog/nixos-on-zfs/)
- [Graham Christensen - Erase your darlings](https://grahamc.com/blog/erase-your-darlings/)
- [Remote, encrypted ZFS storage server with NixOS](https://mazzo.li/posts/hetzner-zfs.html)
- [ElvishJerricco/stage1-tpm-tailscale](https://github.com/ElvishJerricco/stage1-tpm-tailscale)
