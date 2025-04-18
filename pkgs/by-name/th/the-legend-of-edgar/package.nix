{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  gettext,
  libpng,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "the-legend-of-edgar";
  version = "1.37";

  src = fetchFromGitHub {
    owner = "riksweeney";
    repo = "edgar";
    tag = finalAttrs.version;
    hash = "sha256-hhzDNnoQCwHOwknABTz4a9AQ7MkU9vayi2tZvJtK1PQ=";
  };

  patches = [
    # Fix _FORTIFY_SOURCE startup crash:
    #   https://github.com/riksweeney/edgar/pull/67
    (fetchpatch {
      url = "https://github.com/riksweeney/edgar/commit/cec80a04d765fd2f6563d1cf060ad5000f9efe0a.patch";
      hash = "sha256-RJpIt7M3c989nXkWRTY+dIUGqqttyTTGx8s5u/iTWX4=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libpng
    zlib
  ];

  dontConfigure = true;

  makefile = "makefile";

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "BIN_DIR=${placeholder "out"}/bin/"
  ];

  enableParallelBuilding = true;

  meta = {
    homepage = "https://www.parallelrealities.co.uk/games/edgar";
    description = "2D platform game with a persistent world";
    longDescription = ''
      When Edgar's father fails to return home after venturing out one dark and
      stormy night, Edgar fears the worst: he has been captured by the evil
      sorcerer who lives in a fortress beyond the forbidden swamp.

      Donning his armour, Edgar sets off to rescue him, but his quest will not
      be easy...

      The Legend of Edgar is a platform game, not unlike those found on the
      Amiga and SNES. Edgar must battle his way across the world, solving
      puzzles and defeating powerful enemies to achieve his quest.
    '';
    license = lib.licenses.gpl1Plus;
    mainProgram = "edgar";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
