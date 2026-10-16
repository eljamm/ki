{
  flake-inputs ? import (fetchTarball {
    url = "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0";
    sha256 = "1j57avx2mqjnhrsgq3xl7ih8v7bdhz1kj3min6364f486ys048bm";
  }),
  flakeSelf ? flake-inputs.import-flake { src = ./.; },
  inputs ? flakeSelf.inputs,
  system ? builtins.currentSystem,
  pkgs ? import inputs.nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  lib ? import "${inputs.nixpkgs}/lib",
}:
let
  default = lib.makeScope pkgs.newScope (self: {
    inherit
      lib
      pkgs
      inputs
      flake
      flakeSelf
      system
      default # recurse scope
      ;

    formatter = self.callPackage ./nix/formatter.nix { };
    shells = self.callPackage ./nix/shells.nix { };

    devPkgs = {
    };

    overlays = {
      default = final: prev: self.devPkgs;
    };
  });

  flake = default.callPackage ./nix/flake { };
in
default
