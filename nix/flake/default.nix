{
  lib,
  default,
  ...
}:
lib.makeExtensible (self: {
  systemAgnostic = {
    inherit (default)
      overlays
      ;
  };

  perSystem = {
    devShells = lib.removeAttrs default.shells [
      # TODO: use custom scope:
      # https://github.com/ngi-nix/ngipkgs/blob/e743e792/pkgs/lib.nix#L38-L40
      #
      # Flakes want attributes to be a derivation, so including these
      # functions makes the evaluation fail. They come from the scope's
      # `callPackage`, which we use for convenience.
      "override"
      "overrideDerivation"
    ];
    formatter = default.formatter.package;
    packages = default.devPkgs;
    checks = self.perSystem.packages // {
      pre-commit-hook = default.formatter.hooks.pre-commit.script-ci;
    };
  };
})
