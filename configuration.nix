# Bootstrap config for initial SD card boot
# NVMe drives are auto-mounted at /data and /backup
{ pkgs, lib, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    htop
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    openFirewall = true;
  };

  users.users.rk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "rk3588";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = true;

  system.stateVersion = "24.05";
}
