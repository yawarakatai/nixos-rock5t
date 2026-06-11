# nixos-rock5t

NixOS SD card image builder for [Radxa ROCK 5T](https://docs.radxa.com/en/rock5/rock5t) (RK3588).

## Build

```bash
nix build .#nixosConfigurations.dane.config.system.build.sdImage -L
# Output: result/sd-image/dane-sd-image-*.img.zst
```

Write to SD card:

```bash
zstd -d -c result/sd-image/dane-sd-image-*.img.zst | \
  sudo dd of=/dev/sdX bs=4M status=progress oflag=sync
```

## Serial console

UART2 on the 40-pin GPIO header:

| Pin | Signal |
|---|---|
| 6 | GND |
| 8 | TX |
| 10 | RX |

Baud rate: **1,500,000**, 8N1, no flow control.

**Use a CP2102 or FT232R adapter.** CH340 adapters cannot reliably produce 1.5 Mbps, resulting in garbled output or no input. The adapter's TX connects to Pin 10 (board RX), RX to Pin 8 (board TX).

## Device-specific notes

### SPI NOR flash

ROCK 5T has a 16 MiB SPI NOR flash. Boot priority: **SPI → eMMC → SD**. If UEFI/EDK2 was previously flashed to SPI, the SD card will be ignored. Erase with:

```bash
nix develop
# Connect USB-C, hold Maskrom button, apply DC 12V power
lsusb | grep -i rock          # should show 2207:350a
sudo rkdeveloptool db rk3588_spl_loader_v1.12.bin
sudo rkdeveloptool ef
```

### PCIe / 2.5GbE

The dual RTL8125B 2.5GbE NICs may show `PCIe-0 Link Fail` in U-Boot. This is harmless — the Linux kernel re-initializes them successfully. Both ports should work after boot.

### ext4 partition sizing

The sd-image builder may produce an ext4 filesystem slightly larger than its GPT partition. If the root mount fails with a superblock/device size mismatch, this flake includes a post-build workaround (`truncate -s +8M` + `sfdisk -N2`).

### Blue LED heartbeat

A double-blink repeating pattern on the blue LED indicates the kernel is running. This is normal.

## Architecture

```
nixos-rock5t/
├── flake.nix                         # Entry: nixosModules.rock5t + nixosConfigurations.dane
├── pkgs/u-boot-rock5t/               # U-Boot extracted from Radxa official image
├── modules/
│   ├── boards/rock5t.nix             # Device tree, kernel params, base config
│   └── sd-image/rock5t.nix           # GPT layout, extlinux, U-Boot offsets, ext4 padding
└── configuration.nix                 # Minimal example (no personal config)
```

## Acknowledgments

- [ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588) (MIT) — board infrastructure, GPT sd-image builder
- [armbian/rkbin](https://github.com/armbian/rkbin) — Rockchip firmware
- [radxa-build/rock-5t](https://github.com/radxa-build/rock-5t) — official U-Boot images

## License

MIT
