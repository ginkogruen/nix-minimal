# nix-minimal

Minimal opinionated NixOS configuration to be used as a base system to build upon.

The Aim is to provide a structure for all things which have to be done
on install and can't easily be changed later.

It should also be possible to set this up with minimal interaction and effort.

## Functionality goals

I aim to hit the following functionality goals for my systems:

- [x] Declarative partitioning using [disko](https://github.com/nix-community/disko)
- [ ] Systemd-boot as bootloader
- [x] ZFS filesystem
- [x] Full disk encryption with ZFS encryption
- [ ] Encryption unlockable through SSH
- [ ] SWAP partition
- [ ] Impermanence setup for NixOS and home-manager
- [ ] Impermanence rollback via ZFS snapshot
- [ ] Secrets management using [sops-nix](https://github.com/Mic92/sops-nix)
- [ ] Documentation for how things work
- [ ] Setup with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [ ] Optional secure boot with [lanzaboote](https://github.com/nix-community/lanzaboote)

I may not hit every one of these goals so these are subject to change.

## Documentation resources & inspiration

- [Graham Christensen - ZFS Datasets for NixOS](https://grahamc.com/blog/nixos-on-zfs/)
- [Graham Christensen - Erase your darlings](https://grahamc.com/blog/erase-your-darlings/)
- [Remote, encrypted ZFS storage server with NixOS](https://mazzo.li/posts/hetzner-zfs.html)
- [ElvishJerricco/stage1-tpm-tailscale](https://github.com/ElvishJerricco/stage1-tpm-tailscale)
