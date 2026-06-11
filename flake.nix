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
      # Board config module — import this in nix-config
      nixosModules.rock5t = {
        imports = [
          ./modules/boards/rock5t.nix
        ];
        # Provide the path to nixos-rk3588's internal modules
        _module.args.rk3588-modules = "${nixos-rk3588}/modules";
      };

      # Full SD image build config — for initial install only
      nixosConfigurations.dane = nixpkgs.lib.nixosSystem {
        system = aarch64System;

        specialArgs = {
          rk3588-modules = "${nixos-rk3588}/modules";
        };

        modules = [
          self.nixosModules.rock5t
          ./modules/sd-image/rock5t.nix
          ./configuration.nix
          {
            networking.hostName = "dane";
            sdImage.imageBaseName = "dane-sd-image";
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          nix
          screen
          minicom
          tio
          rkdeveloptool
          usbutils
        ];
        shellHook = ''
          echo "  nixos-rock5t devshell"
          echo ""
          echo "  Build SD image:  nix build .#nixosConfigurations.dane.config.system.build.sdImage -L"
          echo "  Serial console:  tio /dev/ttyUSB0 -b 1500000"
        '';
      };
    };
}
