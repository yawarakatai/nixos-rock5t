# Rock 5T Board Configuration
{ rk3588-modules, lib, ... }:

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
      "console=ttyS2,1500000n8"
      "coherent_pool=2M"
      "irqchip.gicv3_pseudo_nmi=0"
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
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
