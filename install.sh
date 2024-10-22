# After cloning https://github.com/ginkogruen/nix-minimal.git into the home dir
# Run this script to set up the install itself.

# Generate hardware-configuration.nix and configuration.nix
nixos-generate-config --root /tmp/config --no-filesystems

# Copy contents of nix-minimal into location
cp ~/nix-minimal/. /tmp/config/etc/nixos/

# Delete generated configuration.nix
rm /tmp/config/etc/nixos/configuration.nix

# Overwrite existing hardware config with generated one
mv /tmp/config/etc/nixos/hardware-configuration.nix /tmp/config/etc/nixos/hosts/titan/hardware-configuration.nix

# Run disko-install command and write boot entry
sudo nix run --extra-experimental-features "nix-command flakes" 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake '/tmp/config/etc/nixos#titan' --disk main /dev/nvme0n1
