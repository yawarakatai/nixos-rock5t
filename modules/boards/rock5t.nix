# Rock 5T Board Configuration
{ inputs, lib, ... }:

let
  nixos-rk3588' =
    if inputs ? nixos-rock5t
    then inputs.nixos-rock5t.inputs.nixos-rk3588
    else inputs.nixos-rk3588;
  rk3588-modules = "${nixos-rk3588'}/modules";
in
{
  imports = [
    "${rk3588-modules}/boards/base.nix"
  ];

  boot = {
    kernelParams = [
      "rootwait"
      "rw"
      "earlycon"
      "consoleblank=0"
      "coherent_pool=2M"
      "irqchip.gicv3_pseudo_nmi=0"
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
      "console=ttyS2,1500000n8"
    ];
  };

  hardware = {
    deviceTree = {
      name = "rockchip/rk3588-rock-5t.dtb";
      overlays = [];
    };

    firmware = [];
  };
}
