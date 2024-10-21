# common-modules

This directory is meant for modules that share configuration across `nixos`,
`nix-darwin` and `home-manager` (& possible other systems).
Option declared in these modules must refer to the location of the
common-modules importing these shared modules.
