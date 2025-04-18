{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nixosTests,
}:

buildGoModule rec {
  pname = "ergo";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "ergochat";
    repo = "ergo";
    tag = "v${version}";
    sha256 = "sha256-8qZ5pnbCYN/j8B5cS456HVK2hDGqJwrPo1k4oagJrqU=";
  };

  vendorHash = null;

  passthru.tests.ergochat = nixosTests.ergochat;

  meta = {
    changelog = "https://github.com/ergochat/ergo/blob/v${version}/CHANGELOG.md";
    description = "Modern IRC server (daemon/ircd) written in Go";
    mainProgram = "ergo";
    homepage = "https://github.com/ergochat/ergo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      lassulus
      tv
    ];
    platforms = lib.platforms.linux;
  };
}
