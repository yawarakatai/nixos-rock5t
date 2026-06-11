# Minimal example configuration for SD image build
# Personal settings (users, SSH keys, services) belong in nix-config
{ lib, ... }:

{
  networking.useDHCP = lib.mkDefault true;

  system.stateVersion = "24.05";
}
