{
  stdenv,
  lib,
  nixosTests,
  fetchFromGitHub,
  fetchpatch,
  nodejs,
  pnpm_9,
  makeWrapper,
  python3,
  bash,
  jemalloc,
  ffmpeg-headless,
  writeShellScript,
  xcbuild,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "misskey";

  version = "2024.11.0";

  src = fetchFromGitHub {
    owner = "misskey-dev";
    repo = "misskey";
    tag = finalAttrs.version;
    hash = "sha256-uei5Ojx39kCbS8DCjHZ5PoEAsqJ5vC6SsFqIEIJ16n8=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      # https://github.com/misskey-dev/misskey/security/advisories/GHSA-w98m-j6hq-cwjm
      name = "CVE-2025-24896.patch";
      url = "https://github.com/misskey-dev/misskey/commit/ba9f295ef2bf31cc90fa587e20b9a7655b7a1824.patch";
      hash = "sha256-jNl2AdLaG3v8QB5g/UPTupdyP1yGR0WcWull7EA7ogs=";
    })
  ];

  nativeBuildInputs = [
    nodejs
    pnpm_9.configHook
    makeWrapper
    python3
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ xcbuild.xcrun ];

  # https://nixos.org/manual/nixpkgs/unstable/#javascript-pnpm
  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-YWZhm5eKjB6JGP45WC3UrIkr7vuBUI4Q3oiK8Lst3dI=";
  };

  buildPhase = ''
    runHook preBuild

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617546739
    (
      cd node_modules/.pnpm/node_modules/v-code-diff
      pnpm run postinstall
    )

    # https://github.com/NixOS/nixpkgs/pull/296697/files#r1617595593
    export npm_config_nodedir=${nodejs}
    (
      cd node_modules/.pnpm/node_modules/re2
      pnpm run rebuild
    )
    (
      cd node_modules/.pnpm/node_modules/sharp
      pnpm run install
    )

    pnpm build

    runHook postBuild
  '';

  installPhase =
    let
      checkEnvVarScript = writeShellScript "misskey-check-env-var" ''
        if [[ -z $MISSKEY_CONFIG_YML ]]; then
          echo "MISSKEY_CONFIG_YML must be set to the location of the Misskey config file."
          exit 1
        fi
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/data
      cp -r . $out/data

      # Set up symlink for use at runtime
      # TODO: Find a better solution for this (potentially patch Misskey to make this configurable?)
      # Line that would need to be patched: https://github.com/misskey-dev/misskey/blob/9849aab40283cbde2184e74d4795aec8ef8ccba3/packages/backend/src/core/InternalStorageService.ts#L18
      # Otherwise, maybe somehow bindmount a writable directory into <package>/data/files.
      ln -s /var/lib/misskey $out/data/files

      makeWrapper ${pnpm_9}/bin/pnpm $out/bin/misskey \
        --run "${checkEnvVarScript} || exit" \
        --chdir $out/data \
        --add-flags run \
        --set-default NODE_ENV production \
        --prefix PATH : ${
          lib.makeBinPath [
            nodejs
            pnpm_9
            bash
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            jemalloc
            ffmpeg-headless
            stdenv.cc.cc
          ]
        }

      runHook postInstall
    '';

  passthru = {
    inherit (finalAttrs) pnpmDeps;
    tests.misskey = nixosTests.misskey;
  };

  meta = {
    description = "🌎 An interplanetary microblogging platform 🚀";
    homepage = "https://misskey-hub.net/";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.feathecutie ];
    platforms = lib.platforms.unix;
    mainProgram = "misskey";
  };
})
