# Rock 5T Headless Server Configuration
{ config, pkgs, lib, ... }:

let
  username = "rk";
  hashedPassword = "$y$j9T$V7M5HzQFBIdfNzVltUxFj/$THE5w.7V7rocWFm06Oh8eFkAKkUFb5u6HVZvXyjekK6";
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    htop
    btop
    lm_sensors
    mtr
    iperf3
    tcpdump
    tmux
  ];

  programs.mtr.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
    openFirewall = true;
  };

  users.users."${username}" = {
    inherit hashedPassword;
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "users" "wheel" ];
    openssh.authorizedKeys.keys = [ ];
  };

  users.users.root = {
    inherit hashedPassword;
  };

  boot.initrd.systemd.emergencyAccess = true;

  # Podman for OCI containers
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.backend = "podman";
  };

  networking = {
    firewall.enable = true;
    useDHCP = lib.mkDefault true;
  };

  system.stateVersion = "24.05";
}
