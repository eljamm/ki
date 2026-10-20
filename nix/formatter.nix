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
    programs.ruff-format.enable = true; # python

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
        hooks.actionlint.enable = true;
        hooks.ruff.enable = true;
        hooks.treefmt.enable = true;
        hooks.treefmt.packageOverrides.treefmt = self.package;
        hooks.zizmor.enable = true;
        # https://pre-commit.com/#confining-hooks-to-run-at-certain-stages
        hooks.actionlint.stages = [ "manual" ];
        hooks.ruff.stages = [ "manual" ];
        hooks.zizmor.stages = [ "manual" ];
      };

      shellHook = self'.check.shellHook;

      config = self'.check.config;

      script = pkgs.writeShellScriptBin "pre-commit-run" ''
        run() {
          ${lib.getExe self'.config.package} run \
            --all-files \
            --config \
          ${self'.config.configFile} \
            "$@"
        }

        run # treefmt
        run --hook-stage manual
      '';

      script-ci =
        pkgs.runCommand "pre-commit-run-ci"
          {
            nativeBuildInputs = with pkgs; [
              gitMinimal
              writableTmpDirAsHomeHook
            ];
          }
          # bash
          ''
            cp -R ${root} "$HOME/root"
            chmod -R u+w "$HOME/root"
            cd "$HOME/root"

            git init -q
            git add .
            git -c user.name=CI -c user.email=ci@sandbox commit -qm init

            ${lib.getExe self'.script} | tee $out
          '';
    });
  };
})
