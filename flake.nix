{
  description = "My emacs Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-config.url = "github:larstvei/dot-emacs";
  };

  outputs = { self, nixpkgs, flake-utils, emacs-overlay, emacs-config }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            emacs-overlay.overlays.emacs
            emacs-overlay.overlays.package
          ];
        };
      in {
        defaultPackage = pkgs.emacsWithPackagesFromUsePackage {
          config = emacs-config + "/init.org";
          defaultInitFile = true;
          alwaysEnsure = true;
          alwaysTangle = true;
          extraEmacsPackages = epkgs:
            [ epkgs.treesit-grammars.with-all-grammars ];
        };
      });
}
