# .nixfiles

Configuration for my systems written in Nix.

## Option naming convention

Options are named according to the **file** they are declared in and its
**location** in the repository.
In order to differentiate options created by me from other options they are
prefixed by the keyword `custom`.
The folders `hm-modules` and `nixos-modules` are not specified in the option
name because they are implicit.

Examples:

- `custom.windowManager.cosmic.enable` is an option enabling cosmic
window manager located in `/nixos-modules/windowManager/cosmic.nix`
- `custom.emacs.enable` is an option enabling emacs related
configuration located in `/hm-modules/emacs/emacs.nix`
