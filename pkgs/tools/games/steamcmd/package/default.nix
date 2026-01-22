# Modified steamcmd for maximum container compatibility

{
  lib,
  stdenv,
  fetchurl,
  bash,
  coreutils,
  glibc,
  gcc-unwrapped,
  steamRoot ? "~/.local/share/Steam",
}:

stdenv.mkDerivation {
  pname = "steamcmd";
  version = "20180104";

  src = fetchurl {
    url = "https://web.archive.org/web/20240521141411/https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz";
    hash = "sha256-zr8ARr/QjPRdprwJSuR6o56/QVXl7eQTc7V5uPEHHnw=";
  };

  preUnpack = ''
    mkdir $name
    cd $name
    sourceRoot=.
  '';

  buildInputs = [
    bash
    coreutils
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/steamcmd/linux32
    install -Dm755 steamcmd.sh $out/share/steamcmd/steamcmd.sh
    install -Dm755 linux32/* $out/share/steamcmd/linux32

    mkdir -p $out/bin
    substitute ${./steamcmd.sh} $out/bin/steamcmd \
      --subst-var out \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by steamRoot "${steamRoot}" \
      --subst-var-by glibc ${glibc} \
      --subst-var-by gccLib ${gcc-unwrapped.lib}
    chmod 0755 $out/bin/steamcmd
  '';

  meta = {
    homepage = "https://developer.valvesoftware.com/wiki/SteamCMD";
    description = "Steam command-line tools";
    mainProgram = "steamcmd";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ tadfisher ];
  };
}
