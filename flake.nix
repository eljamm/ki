{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # import flake attributes from ./flake/default.nix
  outputs =
    { self, ... }@inputs:
    let
      flakeSelf = self;

      inherit (inputs.flake-utils.lib)
        eachSystem
        eachSystemPassThrough
        ;

      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      getDefault = system: (import ./. { inherit flakeSelf inputs system; });
      importFlake = arg: system: (getDefault system).flake.${arg} or { };

      # independant of system (e.g. nixosModules)
      systemAgnosticFlake = eachSystemPassThrough systems (importFlake "systemAgnostic");

      # depends on system (e.g. packages.x86_64-linux)
      perSystemFlake = eachSystem systems (importFlake "perSystem");
    in
    systemAgnosticFlake // perSystemFlake;
}
