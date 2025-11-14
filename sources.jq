["aarch64-linux", "x86_64-linux", "aarch64-macos", "x86_64-macos", "aarch64-windows", "x86_64-windows"] as $targets |

def todarwin(x): x | gsub("macos"; "darwin");

def filename(x): x | match("zig-.+-.+-.+.+\\.(?:tar\\.xz|zip)"; "g") | .string;

def toentry(vsn; x):
  [(vsn as $version |
    .value |
    to_entries[] |
    select(.key as $key | any($targets[]; . == $key)) | {
      (todarwin(.key)): {
        "file": filename(.value.tarball),
        "sha256": .value.shasum,
        "version": $version,
      }
    }
  )] | add | first(values, {});

reduce to_entries[] as $entry ({}; . * (
  $entry | {
    (.key): (
        toentry(.value.version // .key; .value)
    )
  }
))
