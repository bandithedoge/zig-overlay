{
  pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem,
}: let
  inherit (pkgs) lib;
  sources = builtins.fromJSON (lib.strings.fileContents ./sources.json);

  # mkBinaryInstall makes a derivation that installs Zig from a binary.
  mkBinaryInstall = {
    url,
    version,
    sha256,
  }:
    pkgs.stdenv.mkDerivation (finalAttrs: {
      inherit version;

      pname = "zig";
      src = pkgs.fetchurl {inherit url sha256;};
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out/{doc,bin,lib}
        [ -d docs ] && cp -r docs/* $out/doc
        [ -d doc ] && cp -r doc/* $out/doc
        cp -r lib/* $out/lib
        cp zig $out/bin/zig
      '';

      passthru.hook = pkgs.zig.hook.override {zig = finalAttrs.finalPackage;};

      meta = with pkgs.lib; {
        description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
        homepage = "https://ziglang.org/";
        license = licenses.mit;
        maintainers = [];
        platforms = platforms.unix;
      };
    });

  # The packages that are tagged releases
  taggedPackages =
    lib.attrsets.mapAttrs
    (k: v: mkBinaryInstall {inherit (v.${system}) version url sha256;})
    (lib.attrsets.filterAttrs
      (k: v:
        (builtins.hasAttr system v)
        && (v.${system}.url != null)
        && (v.${system}.sha256 != null)
        && !(lib.strings.hasSuffix "mach" k))
      (builtins.removeAttrs sources ["master" "mach-latest"]));

  # The master packages
  masterPackages =
    lib.attrsets.mapAttrs' (
      k: v:
        lib.attrsets.nameValuePair
        (
          if k == "latest"
          then "master"
          else ("master-" + k)
        )
        (mkBinaryInstall {inherit (v.${system}) version url sha256;})
    )
    (lib.attrsets.filterAttrs
      (k: v: (builtins.hasAttr system v) && (v.${system}.url != null))
      sources.master);

  # Mach nominated versions
  # https://machengine.org/docs/nominated-zig/
  machPackages =
    lib.attrsets.mapAttrs
    (k: v: mkBinaryInstall {inherit (v.${system}) version url sha256;})
    (lib.attrsets.filterAttrs (k: v: lib.strings.hasSuffix "mach" k)
      (builtins.removeAttrs sources ["master"]));

  # This determines the latest /released/ version.
  latest = lib.lists.last (
    builtins.sort
    (x: y: (builtins.compareVersions x y) < 0)
    (builtins.attrNames taggedPackages)
  );

  # Latest Mach nominated version
  machLatest = lib.lists.last (
    builtins.sort
    (x: y: (builtins.compareVersions x y) < 0)
    (builtins.attrNames machPackages)
  );
in
  # We want the packages but also add a "default" that just points to the
  # latest released version.
  taggedPackages
  // masterPackages
  // machPackages
  // {
    "default" = taggedPackages.${latest};
    mach-latest = machPackages.${machLatest};
  }
