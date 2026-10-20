{
  lib,
  pkgs,
  inputs,

  system,
  root,
  ...
}:
lib.makeExtensible (self: {
  treefmt = import inputs.treefmt-nix;

  config = {
    projectRootFile = "default.nix";

    programs.nixfmt.enable = true;

    # python
    programs.ruff-format.enable = true;

    # ci
    programs.actionlint.enable = true;
    programs.zizmor.enable = true;

    # misc
    settings.formatter.editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      priority = 9; # last
    };
  };

  # evaluated config
  eval = self.treefmt.evalModule pkgs self.config;
  configFile = self.eval.config.build.configFile;

  # treefmt package
  package = self.eval.config.build.wrapper;

  # development shell that contains all formatters
  shell = self.eval.config.build.devShell;

  hooks = {
    pre-commit = lib.fix (self': {
      check = inputs.git-hooks.lib.${system}.run {
        src = root;
        hooks.treefmt.enable = true;
        hooks.treefmt.packageOverrides.treefmt = self.package;
        hooks.ruff.enable = true;
        # https://pre-commit.com/#confining-hooks-to-run-at-certain-stages
        hooks.ruff.stages = [ "manual" ];
      };

      config = self'.check.config;

      script = pkgs.writeShellScriptBin "pre-commit-run" ''
        ${lib.getExe self'.config.package} run \
          --all-files \
          --config \
        ${self'.config.configFile}
      '';

      shellHook = self'.check.shellHook;
    });
  };
})
