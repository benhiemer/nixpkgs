{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  gtest,
  openssl,
  pe-parse,
}:

stdenv.mkDerivation rec {
  pname = "uthenticode";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "uthenticode";
    tag = "v${version}";
    hash = "sha256-NGVOGXMRlgpSRw56jr63rJc/5/qCmPjtAFa0D21ogd4=";
  };

  cmakeFlags = [
    "-DBUILD_TESTS=1"
    "-DUSE_EXTERNAL_GTEST=1"
  ];

  nativeBuildInputs = [ cmake ];
  nativeCheckInputs = [ gtest ];
  buildInputs = [
    pe-parse
    openssl
  ];

  doCheck = true;
  checkPhase = "test/uthenticode_test";

  meta = with lib; {
    description = "Small cross-platform library for verifying Authenticode digital signatures";
    homepage = "https://github.com/trailofbits/uthenticode";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ arturcygan ];
  };
}
