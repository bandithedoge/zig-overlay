[
  "aarch64-linux",
  "armv7a-linux",
  "loongarch64-linux",
  "powerpc64le-linux",
  "riscv64-linux",
  "s390x-linux",
  "x86_64-linux",

  "aarch64-macos",
  "x86_64-macos"
] as $targets |

def todarwin(x): x | gsub("macos"; "darwin");

def filename(x): x | match("zig-.+-.+-.+.+\\.(?:tar\\.xz|zip)"; "g") | .string;

def toentry(vsn; x):
  [(vsn as $version |
    .value |
    to_entries[] |
    select(.key as $key | any($targets[]; . == $key)) | {
      (todarwin(.key)): {
        "file": filename(.value.tarball),
        "url": .value.tarball,
        "sha256": .value.shasum,
        "version": $version,
      }
    }
  )] | add;

reduce to_entries[] as $entry ({}; . + (
  $entry | {
    (.key): (
        toentry(.value.version // .key; .value)
    )
  }
))
+ {
  "master": { (.master.date): ( {"key": .master.version, "value": .master} | toentry(.key; .))}
} | with_entries (select(.value != null))
