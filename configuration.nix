# Bootstrap config for initial SD card boot
# Deploy your real config after boot: nixos-rebuild boot --flake your-flake#hostname
{ pkgs, lib, ... }:

{
  time.timeZone = "Asia/Tokyo";

  environment.systemPackages = with pkgs; [ git curl neovim htop ];

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

  networking.useDHCP = lib.mkDefault true;
  networking.firewall.enable = true;

  system.stateVersion = "24.05";
}
