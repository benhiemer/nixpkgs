{
  lib,
  fetchFromGitHub,
  fluxbox,
  gnused,
  makeWrapper,
  perlPackages,
  replaceVars,
  xorg,
  wrapGAppsHook3,
  gitUpdater,
}:

perlPackages.buildPerlPackage rec {
  pname = "fbmenugen";
  version = "0.87";

  src = fetchFromGitHub {
    owner = "trizen";
    repo = "fbmenugen";
    tag = version;
    sha256 = "A0yhoK/cPp3JlNZacgLaDhaU838PpFna7luQKNDvyOg=";
  };

  patches = [
    (replaceVars ./0001-Fix-paths.patch {
      xmessage = xorg.xmessage;
      inherit fluxbox gnused;
      # replaced in postPatch
      fbmenugen = null;
    })
  ];

  outputs = [ "out" ];

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    fluxbox
    gnused
    perlPackages.DataDump
    perlPackages.FileDesktopEntry
    perlPackages.Gtk3
    perlPackages.LinuxDesktopFiles
    perlPackages.perl
    xorg.xmessage
  ];

  dontConfigure = true;

  dontBuild = true;

  postPatch = ''
    substituteInPlace fbmenugen --subst-var-by fbmenugen $out
  '';

  installPhase = ''
    runHook preInstall
    install -D -t $out/bin fbmenugen
    install -D -t $out/etc/xdg/fbmenugen schema.pl
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/fbmenugen" --prefix PERL5LIB : "$PERL5LIB"
  '';

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/trizen/fbmenugen";
    description = "Simple menu generator for the Fluxbox Window Manager";
    mainProgram = "fbmenugen";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.romildo ];
  };
}
