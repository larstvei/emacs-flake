{
  description = "My emacs Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-config = {
      url = "github:larstvei/dot-emacs";
      flake = false;
    };
    emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      emacs-overlay,
      emacs-plus,
      emacs-config,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            emacs-overlay.overlays.emacs
            emacs-overlay.overlays.package
          ];
        };

        emacsDarwin = (pkgs.emacs-unstable).overrideAttrs (_: {
          patches = [
            "${emacs-plus}/patches/emacs-30/round-undecorated-frame.patch"
            "${emacs-plus}/patches/emacs-30/system-appearance.patch"
          ];
        });

        emacsLinux = pkgs.emacs-unstable-pgtk;

        emacsPkg = if pkgs.stdenv.isDarwin then emacsDarwin else emacsLinux;
      in
      {
        defaultPackage = pkgs.emacsWithPackagesFromUsePackage {
          config = "${emacs-config}/init.org";
          package = emacsPkg;
          defaultInitFile = true;
          alwaysEnsure = true;
          alwaysTangle = true;
          extraEmacsPackages = epkgs: [
            epkgs.treesit-grammars.with-all-grammars
            epkgs.jinx
            epkgs.mu4e
          ];
        };

        devShell = pkgs.mkShell { buildInputs = [ pkgs.jq ]; };
      }
    );
}
