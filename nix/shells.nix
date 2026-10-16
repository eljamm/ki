{
  pkgs,
  default,
  formatter,
  ...
}:
{
  default = pkgs.mkShellNoCC {
    inputsFrom = [
      formatter.shell
    ];

    packages = with pkgs; [
      default.devPkgs.ki.pyEnv
      formatter.package
      gitMinimal
    ];

    shellHook = # bash
      ''
        export PROJECT_ROOT="$(git rev-parse --show-toplevel)"

        # better compat with certain IDEs
        ln -sf "${formatter.configFile}" "$PROJECT_ROOT/treefmt.toml"
      '';
  };
}
