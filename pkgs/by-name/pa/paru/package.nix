{
  lib,
  rustPlatform,
  fetchFromGitHub,
  gettext,
  installShellFiles,
  pkg-config,
  libarchive,
  openssl,
  pacman,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "paru";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "Morganamilo";
    repo = "paru";
    tag = "v${version}";
    hash = "sha256-VFIeDsIuPbWGf+vio5i8qGUBB+spP/7SwYwmQkMjtL8=";
  };

  cargoPatches = [
    ./cargo-lock.patch
  ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-3tKoL2I6DHrRodhWFOi3mSxk2P5SxCush/Hz9Dpyo3U=";

  nativeBuildInputs = [
    gettext
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libarchive
    openssl
    pacman
  ];

  # https://github.com/Morganamilo/paru/issues/1154#issuecomment-2002357898
  buildFeatures = lib.optionals stdenv.hostPlatform.isAarch64 [
    "generate"
  ];

  postBuild = ''
    sh ./scripts/mkmo locale/
  '';

  postInstall = ''
    installManPage man/paru.8 man/paru.conf.5
    installShellCompletion --name paru.bash --bash completions/bash
    installShellCompletion --name paru.fish --fish completions/fish
    installShellCompletion --name _paru --zsh completions/zsh
    cp -r locale "$out/share/"
  '';

  meta = {
    description = "Feature packed AUR helper";
    homepage = "https://github.com/Morganamilo/paru";
    changelog = "https://github.com/Morganamilo/paru/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ wegank ];
    mainProgram = "paru";
    platforms = lib.platforms.linux;
  };
}
