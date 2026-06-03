{ stdenv, fetchurl, xz }:

stdenv.mkDerivation {
  pname = "u-boot-rock5t";
  version = "r6";

  src = fetchurl {
    url = "https://github.com/radxa-build/rock-5t/releases/download/rsdk-r6/rock-5t_bookworm_kde_r6.output_512.img.xz";
    hash = "sha512-ASeofy2GXPRICzrzWm/9rRXh3dEVIIRGfz/VfGS+B3tGyMGqFXu48sMxwKwsf6NZqKZNV/yQIH0zXh8TZyjT6zRoY3KsfqdG1FFQ9k5SmMhL7E7/2OvFauy41v3v5SfB2uf0rVh+YLadOF4FcUdhSFBrDD2s+28Kv3AP5FSMrf3Hj3bHXzC2S+dCHcxL7KpACn9glSjLA==";
  };

  nativeBuildInputs = [ xz ];

  buildCommand = ''
    mkdir -p $out

    # Stream-decompress and extract both U-Boot parts in a single pass
    xz -d -c $src | {
      # idbloader.img at sector 64 (offset 32768)
      dd bs=512 count=64 of=/dev/null
      dd bs=512 count=2048 of=$out/idbloader.img

      # u-boot.itb at sector 16384 (offset 8388608)
      # Already read 64+2048=2112 sectors, skip to sector 16384
      dd bs=512 count=14272 of=/dev/null
      dd bs=512 count=8192 of=$out/u-boot.itb
    }
  '';
}
