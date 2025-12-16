{
  description = "Zig compiler binaries.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      forAllSystems =
        fn:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: fn nixpkgs.legacyPackages.${system});
    in
    {
      # The packages exported by the Flake:
      #  - default - latest /released/ version
      #  - <version> - tagged version
      #  - master - latest nightly (updated daily)
      #  - master-<date> - nightly by date
      packages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });

      # "Apps" so that `nix run` works. If you run `nix run .` then
      # this will use the latest default.
      apps = forAllSystems (
        pkgs:
        builtins.mapAttrs (_: pkg: {
          type = "app";
          program = pkg + "/bin/zig";
        }) self.packages.${pkgs.stdenv.hostPlatform.system}
      );

      # nix fmt
      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            curl
            jq
            minisign
          ];
        };
      });

      # Overlay that can be imported so you can access the packages
      # using zigpkgs.master or whatever you'd like.
      overlays.default = final: prev: {
        zigpkgs = self.packages.${prev.stdenv.hostPlatform.system};
      };

      # Template for use with nix flake init
      templates.default = {
        path = ./template;
        description = "A basic, empty development environment.";
      };
    };
}
