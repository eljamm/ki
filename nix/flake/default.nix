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
    devShells = default.shells;
    formatter = default.formatter.package;
    packages = default.devPkgs;
    checks = self.perSystem.packages // {
      pre-commit-hook = default.formatter.hooks.pre-commit.script-ci;
    };
  };
})
