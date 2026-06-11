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
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
    };
    openFirewall = true;
  };

  users.users."${username}" = {
    inherit hashedPassword;
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "users" "wheel" ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKoUC9mEqLf9q8geELb89t8I9P+0JBD2fvm51+jwNuu3AAAABHNzaDo= yubikey_5"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFwdOpc6zvMiZ0zC/NqC2mzEn0B5hdRz1jD2V76vsclLAAAABHNzaDo= yubikey_5c"
    ];
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

  # Print network status to serial console after boot
  systemd.services.show-ip = {
    description = "Show IP addresses on ttyS2";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 5  # Wait for DHCP / link negotiation
      echo "=== Network Status ===" > /dev/ttyS2
      ip -4 addr show | grep -v '127.0.0.1\|lo:' > /dev/ttyS2
      echo "=== Done ===" > /dev/ttyS2
    '';
  };

  system.stateVersion = "24.05";
}
