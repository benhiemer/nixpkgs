{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  gfortran,
  gtest,
  openmp,
}:

stdenv.mkDerivation rec {
  pname = "spglib";
  version = "2.6.0"; # N.B: if you change this, please update: pythonPackages.spglib

  src = fetchFromGitHub {
    owner = "spglib";
    repo = "spglib";
    tag = "v${version}";
    hash = "sha256-rmQYFFfpyUhT9pfQZk1fN5tZWTg40wwtszhPhiZpXs4=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
    gtest
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ openmp ];

  cmakeFlags = [ "-DSPGLIB_WITH_Fortran=On" ];

  doCheck = true;

  meta = with lib; {
    description = "C library for finding and handling crystal symmetries";
    homepage = "https://spglib.github.io/spglib/";
    changelog = "https://github.com/spglib/spglib/raw/v${version}/ChangeLog";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.all;
  };
}
