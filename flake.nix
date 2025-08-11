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
        patched-emacs = (pkgs.emacs-git).overrideAttrs (o: {
          patches = [
            "${emacs-plus}/patches/emacs-31/fix-window-role.patch"
            "${emacs-plus}/patches/emacs-31/round-undecorated-frame.patch"
            "${emacs-plus}/patches/emacs-31/system-appearance.patch"
          ];
        });

      in
      {
        defaultPackage = pkgs.emacsWithPackagesFromUsePackage {
          config = "${emacs-config}/init.org";
          package = patched-emacs;
          defaultInitFile = true;
          alwaysEnsure = true;
          alwaysTangle = true;
          extraEmacsPackages = epkgs: [
            epkgs.treesit-grammars.with-all-grammars
            epkgs.jinx
          ];
        };

        devShell = pkgs.mkShell { buildInputs = [ pkgs.jq ]; };
      }
    );
}
