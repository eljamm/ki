{
  lib,
  pkgs,
  formatter,
  ...
}:
{
  default = pkgs.mkShellNoCC {
    inputsFrom = [
      formatter.shell
    ];

    packages = with pkgs; [
      formatter.hooks.pre-commit.script
      formatter.package
      gitMinimal
      pinact
      uv
    ];

    env = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_PYTHON = lib.getExe pkgs.python3;
    };

    shellHook = # bash
      ''
        export PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

        # better compat with certain IDEs
        ln -sf "${formatter.configFile}" "$PROJECT_ROOT/treefmt.toml"

        # https://pyproject-nix.github.io/pyproject.nix/build.html#pythonpath-leaking-into-unrelated-builds
        unset PYTHONPATH

        uv sync --extra dev --frozen

        # activate python venv
        export VIRTUAL_ENV="$PROJECT_ROOT/.venv"
        export PATH="$VIRTUAL_ENV/bin:$PATH"

        # install git hooks
        ${formatter.hooks.pre-commit.shellHook}
      '';
  };
}
