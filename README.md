# This is a fork of [zig-overlay](https://github.com/mitchellh/zig-overlay)

This is NOT a drop-in replacement. Here are the most notable differences:

- [Mach nominated versions](https://machengine.org/docs/nominated-zig/)
- Mirrors for old nightly builds
- Tracking nixpkgs-unstable
- ZLS packages
- Nightlies keyed by version and commit instead of date
- CLI-friendly version strings

# Nix Flake for Zig

This repository is a Nix flake packaging the [Zig](https://ziglang.org)
compiler and [ZLS](https://github.com/zigtools/zls). The flake mirrors the
binaries built officially by Zig and some mirrors and does not build them from
source.

This repository is meant to be consumed primarily as a flake but the
`default.nix` can also be imported directly by non-flakes, too.

The flake outputs are documented in `flake.nix` but an overview:

- Default package and "app" is the latest released version
- `packages.<version>` for a tagged or nightly release
- `packages.master` for the latest nightly release
- `overlays.default` is an overlay that adds `zigpkgs` to be the packages
  exposed by this flake
- `templates.compiler-dev` to setup a development environment for Zig
  compiler development.

## Usage

### Flake

In your `flake.nix` file:

```nix
{
  inputs.zig.url = "github:bandithedoge/zig-overlay";

  outputs = { self, zig, ... }: {
    ...
  };
}
```

In a shell:

```sh
# run the latest released version
$ nix run 'github:bandithedoge/zig-overlay'
# open a shell with specific released version
$ nix shell 'github:bandithedoge/zig-overlay#0_13_0'
# open a shell with specific nightly version
$ nix shell 'github:bandithedoge/zig-overlay#0_8_0-dev_1140_9270aae07'
# open a shell with latest nightly version
$ nix shell 'github:bandithedoge/zig-overlay#master'
# open a shell with latest Mach nominated version
$ nix shell 'github:bandithedoge/zig-overlay#mach-latest'

# open a shell with latest ZLS
$ nix shell 'github:bandithedoge/zig-overlay#zls-latest'
# open a shell with latest ZLS nightly
$ nix shell 'github:bandithedoge/zig-overlay#zls-master'
# open a shell with ZLS for a specific Zig version
$ nix shell 'github:bandithedoge/zig-overlay#master.zls'

# create a template flake
$ nix flake init -t 'github:bandithedoge/zig-overlay'
```

## FAQ

### Why is a Nightly Missing?

There are two possible reasons:

1. The Zig download JSON that is used to generate this overlay only shows
   the latest _master_ release. It doesn't keep track of historical releases.
   If this overlay wasn't running or didn't exist at the time of a release,
   we could miss a day. This is why historical dates beyond a certain point
   don't exist; they predate this overlay (or original overlays this derives
   from).

2. The official Zig CI only generates a master release if the CI runs
   full green. During certain periods of development, a full day may go by
   where the master branch of the Zig compiler is broken. In this scenario,
   a master build (aka "nightly") is not built or released at all.

## Thanks

This repo was forked from [@mitchellh](https://github.com/mitchellh/zig-overlay).

The `sources.json` file was originally from another Zig overlay repository
hosted by the username `arqv`. This user and repository was deleted at some
point, so @mitchellh started a new flake based on the same `sources.json` format
they used so he could inherit the history. Thank you for compiling nightly
release information since 2021!
