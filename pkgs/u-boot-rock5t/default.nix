{ stdenv, fetchurl, xz }:

stdenv.mkDerivation {
  pname = "u-boot-rock5t";
  version = "r6";

  src = fetchurl {
    url = "https://github.com/radxa-build/rock-5t/releases/download/rsdk-r6/rock-5t_bookworm_kde_r6.output_512.img.xz";
    hash = "sha256-W1MMh/JOD4PIodROwLCA79yn7bHGfBAPv0rcnS1YSgo=";
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
