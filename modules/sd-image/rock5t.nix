# Rock 5T SD Image Configuration
{ inputs, lib, config, pkgs, ... }:

let
  nixos-rk3588' =
    if inputs ? nixos-rock5t
    then inputs.nixos-rock5t.inputs.nixos-rk3588
    else inputs.nixos-rk3588;
  rk3588-modules = "${nixos-rk3588'}/modules";
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
  uboot = pkgs.callPackage ../../pkgs/u-boot-rock5t { };
in
{
  imports = [
    "${rk3588-modules}/sd-image/sd-image-rock5a.nix"
  ];

  boot = {
    kernelParams = [
      "rootwait"
    ];

    initrd.checkJournalingFS = lib.mkForce false;

    loader = {
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };
  };

  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  sdImage = {
    inherit rootPartitionUUID;

    compressImage = true;

    firmwarePartitionOffset = 32;
    firmwareSize = 256;  # Enough for kernel + initrd + dtb

    populateFirmwareCommands = ''
      mkdir -p firmware/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
        -c ${config.system.build.toplevel} -d firmware/boot
    '';

    populateRootCommands = "";

    # Rockchip boot layout:
    #   sector 64   (0x40)   - idbloader.img (SPL + DDR init)
    #   sector 16384 (0x4000) - u-boot.itb (ATF + U-Boot proper)
    postBuildCommands = ''
      dd if=${uboot}/idbloader.img of=$img seek=64 conv=notrunc
      dd if=${uboot}/u-boot.itb of=$img seek=16384 conv=notrunc
      # Pad 8MiB so ext4 filesystem is safely smaller than partition
      truncate -s +8M $img
      echo ", +" | sfdisk -N2 $img --no-reread
    '';
  };
}
