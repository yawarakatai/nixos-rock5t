{
  description = "NixOS configuration for Radxa ROCK 5T";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-rk3588.url = "github:ryan4yin/nixos-rk3588";
    nixos-rk3588.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-rk3588, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      aarch64System = "aarch64-linux";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          nix
          screen
          minicom
          tio
        ];
        shellHook = ''
          echo "ROCK 5T NixOS build environment"
          echo "  Serial console: tio /dev/ttyUSB0 -b 1500000"
          echo "  Build SD image:  nix build .#nixosConfigurations.rock5t.config.system.build.sdImage -L"
        '';
      };

      nixosConfigurations.rock5t = nixpkgs.lib.nixosSystem {
        system = aarch64System;

        specialArgs = {
          rk3588-modules = "${nixos-rk3588}/modules";
        };

        modules = [
          ./modules/boards/rock5t.nix
          ./modules/sd-image/rock5t.nix
          ./configuration.nix
          {
            networking.hostName = "rock5t";
            sdImage.imageBaseName = "rock5t-sd-image";
          }
        ];
      };
    };
}
