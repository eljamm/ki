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
    checks = self.perSystem.packages;
  };
})
