{
  cmake,
  fetchFromGitHub,
  gitUpdater,
  lib,
  ninja,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pegtl";
  version = "3.2.8";

  src = fetchFromGitHub {
    owner = "taocpp";
    repo = "PEGTL";
    tag = finalAttrs.version;
    hash = "sha256-nPWSO2wPl/qenUQgvQDQu7Oy1dKa/PnNFSclmkaoM8A=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    homepage = "https://github.com/taocpp/pegtl";
    description = "Parsing Expression Grammar Template Library";
    longDescription = ''
      Zero-dependency C++ header-only parser combinator library
      for creating parsers according to a Parsing Expression Grammar (PEG).
    '';
    license = lib.licenses.boost;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
