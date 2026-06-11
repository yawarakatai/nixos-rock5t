# nixos-rock5t

NixOS SD card image builder for the [Radxa ROCK 5T](https://docs.radxa.com/en/rock5/rock5t) single-board computer (RK3588).

## Overview

This flake produces a bootable NixOS SD card image for the ROCK 5T. It is meant to be imported into a personal [nix-config](https://github.com/yawarakatai/nix-config) flake for runtime configuration and remote deployment.

### What this flake provides

| Output | Description |
|---|---|
| `nixosModules.rock5t` | Board config module (device tree, kernel params, base settings). Import this in your nix-config. |
| `nixosConfigurations.dane` | Full SD image build target for initial installation. |
| `devShells.x86_64-linux.default` | Build environment with serial tools and `rkdeveloptool`. |

### What this flake does NOT contain

- Personal user configuration (users, SSH keys, passwords)
- Home-manager settings
- Tailscale, monitoring, or other service config

These belong in your nix-config.

## Architecture

```
nixos-rock5t/
├── flake.nix                         # Entry point
├── pkgs/u-boot-rock5t/               # U-Boot extracted from Radxa official image
├── modules/
│   ├── boards/rock5t.nix             # Board spec: dtb, kernel params
│   └── sd-image/rock5t.nix           # SD image layout: GPT, extlinux, U-Boot offsets
└── configuration.nix                 # Minimal example config
```

### Dependencies

- [ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588) — base board infrastructure (initrd modules, GPT sd-image builder)
- [nixpkgs](https://github.com/NixOS/nixpkgs) (nixos-unstable) — mainline kernel 6.x with native `rk3588-rock-5t.dtb`

## Usage

### Build SD card image

```bash
nix build .#nixosConfigurations.dane.config.system.build.sdImage -L
# Output: result/sd-image/dane-sd-image-*.img.zst
```

### Write to SD card

```bash
zstd -d -c result/sd-image/dane-sd-image-*.img.zst | \
  sudo dd of=/dev/sdX bs=4M status=progress oflag=sync
```

### First boot

ROCK 5T boots from SD card via U-Boot:
1. Insert SD card, connect DC 12V power
2. UART2 serial console: `tio /dev/ttyUSB0 -b 1500000` (pins 6=GND, 8=TX, 10=RX on the 40-pin GPIO header)
3. The system boots to a login prompt

### Remote deployment (via nix-config)

After initial install, deploy updates remotely from your nix-config:

```bash
nixos-rebuild switch --flake ~/nix-config#dane --target-host rk@<ip> --use-remote-sudo
```

## Integration with nix-config

```nix
# In your nix-config flake.nix:
inputs.nixos-rock5t.url = "github:yawarakatai/nixos-rock5t";
inputs.nixos-rock5t.inputs.nixpkgs.follows = "nixpkgs";

# In your nixosConfigurations:
dane = mkHost "dane" profiles.server {
  system = "aarch64-linux";
  extraModules = [ inputs.nixos-rock5t.nixosModules.rock5t ];
};
```

## Serial console

| Parameter | Value |
|---|---|
| Interface | UART2 on 40-pin GPIO header |
| Pins | 6 (GND), 8 (TX), 10 (RX) |
| Baud rate | 1,500,000 |
| Data bits | 8 |
| Stop bits | 1 |
| Parity | None |

**Important:** Use a CP2102 or FT232R USB-TTL adapter. CH340 adapters often cannot reliably produce 1.5 Mbps.

## SPI Flash erase (if needed)

If the board previously had UEFI/EDK2 installed on SPI NOR flash, it must be erased:

```bash
nix develop
# 1. Connect USB-C to ROCK 5T, hold Maskrom button, power on
# 2. Verify: lsusb | grep -i rock
# 3. Load DDR init:
sudo rkdeveloptool db rk3588_spl_loader_v1.12.bin
# 4. Erase:
sudo rkdeveloptool ef
```

## Acknowledgments

- [ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588) (MIT) — base board infrastructure, GPT sd-image builder
- [armbian/rkbin](https://github.com/armbian/rkbin) — Rockchip firmware binaries
- [radxa-build/rock-5t](https://github.com/radxa-build/rock-5t) — official U-Boot images

## License

MIT
