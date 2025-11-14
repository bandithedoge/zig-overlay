{
  description = "An empty project that uses Zig.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    zig.url = "github:bandithedoge/zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:

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
      devShells.default = forAllSystems (
        pkgs:
        pkgs.mkShell {
          packages = [ ];
        }
      );
    };
}
