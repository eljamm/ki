{
  lib,
  pkgs,
  ...
}:
lib.makeExtensible (self: {
  addons = with pkgs.ankiAddons; [
    anki-connect
  ];

  package = pkgs.anki.withAddons self.addons;

  wrapper = pkgs.writeShellApplication {
    name = "anki";
    runtimeInputs = [ self.package ];
    text = ''
      ANKI_BASE="''${ANKI_BASE:-$PWD/.dev/Anki2}"

      echo
      echo "Starting Anki from: '$ANKI_BASE'"
      echo "You can override this with '\$ANKI_BASE'. See: https://docs.ankiweb.net/manual/files#startup-options"
      echo

      # NOTE: fusion is needed for Wayland
      # https://github.com/ankitects/anki/issues/1767
      env QT_STYLE_OVERRIDE="fusion" anki \
        -b "$ANKI_BASE" \
        "$@"
    '';
  };

  pythonPath = "${pkgs.anki.lib}/${pkgs.python3.sitePackages}";
})
