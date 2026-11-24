{ lib
, stdenv
, fetchurl
, unzip
, imagemagick
, buildFHSEnv
, writeShellScript
, makeDesktopItem
, copyDesktopItems
, vlc
, alsa-lib
, libGL
, libglvnd
, udev
, libx11
, libxcursor
, libxrandr
, libxinerama
, libxi
, libxext
, libxfixes
, zlib
, openssl
, glib
, withTurkish ? false
}:

let
  source = import ./source.nix;

  pname = if withTurkish then "funkin-tr" else "funkin";
  version = source.version;

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = "funkin";
    desktopName = if withTurkish then "Friday Night Funkin' (Türkçe)" else "Friday Night Funkin'";
    genericName = "Rhythm Game";
    comment = "A rhythm game produced by The Funkin' Crew Inc.";
    categories = [ "Game" "ArcadeGame" ];
    keywords = [ "fnf" "funkin" "rhythm" "music" ];
  };

  funkin-unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version;

    src = fetchurl {
      url = source.url;
      inherit (source) hash;
    };

    nativeBuildInputs = [ unzip imagemagick ];

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/funkin $out/share/pixmaps $out/share/icons/hicolor/150x150/apps
      cp -r linux/bin/* $out/share/funkin/
      ${lib.optionalString withTurkish ''
        cp -r ${./turkish}/* $out/share/funkin/
      ''}

      # Extract icon directly from upstream assets at build time (no proprietary images stored in repo)
      magick linux/bin/assets/images/icons/icon-bf.png -crop 150x150+0+0 $out/share/pixmaps/funkin.png
      cp $out/share/pixmaps/funkin.png $out/share/icons/hicolor/150x150/apps/funkin.png

      runHook postInstall
    '';
  };

  fhs = buildFHSEnv {
    name = pname;
    targetPkgs = pkgs: with pkgs; [
      vlc
      alsa-lib
      libGL
      libglvnd
      udev
      libx11
      libxcursor
      libxrandr
      libxinerama
      libxi
      libxext
      libxfixes
      zlib
      openssl
      glib
    ];

    runScript = writeShellScript "funkin-run" ''
      DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}"
      mkdir -p "$DATA_DIR"

      # Symlink static assets from nix store into writable data dir
      for item in "${funkin-unwrapped}/share/funkin"/*; do
        base="$(basename "$item")"
        if [ ! -e "$DATA_DIR/$base" ]; then
          ln -s "$item" "$DATA_DIR/$base"
        fi
      done

      # Make sure scores.json can be written by the game
      if [ -L "$DATA_DIR/scores.json" ]; then
        rm -f "$DATA_DIR/scores.json"
      fi
      touch "$DATA_DIR/scores.json" 2>/dev/null || true

      cd "$DATA_DIR"
      exec ./Funkin "$@"
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version;

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [ desktopItem ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/pixmaps $out/share/icons/hicolor/150x150/apps
    ln -s ${fhs}/bin/${pname} $out/bin/${pname}

    cp ${funkin-unwrapped}/share/pixmaps/funkin.png $out/share/pixmaps/funkin.png
    cp ${funkin-unwrapped}/share/icons/hicolor/150x150/apps/funkin.png $out/share/icons/hicolor/150x150/apps/funkin.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Friday Night Funkin' (Linux port with Weekend 1 and libvlc video cutscenes)"
      + (optionalString withTurkish " - Türkçe Hikaye Desteği");
    homepage = "https://github.com/Renan2010/Funkin-Linux";
    license = with licenses; [ asl20 unfree ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
