{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  re,
}:

buildDunePackage rec {
  pname = "calendar";
  version = "3.0.0";
  minimalOCamlVersion = "4.03";

  src = fetchFromGitHub {
    owner = "ocaml-community";
    repo = pname;
    tag = "v${version}";
    sha256 = "sha256-+VQzi6pEMqzV1ZR84Yjdu4jsJEWtx+7bd6PQGX7TiEs=";
  };

  propagatedBuildInputs = [ re ];

  meta = {
    inherit (src.meta) homepage;
    description = "Library for handling dates and times";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.gal_bolle ];
  };
}
