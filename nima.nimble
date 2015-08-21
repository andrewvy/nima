[Package]
name          = "nima"
version       = "0.1.0"
author        = "Andrew Vy"
description   = "Static website generator in Nim"
license       = "MIT"
bin           = "nima"
SkipDirs      = "example"

[Deps]
Requires: "nim >= 0.10.0, docopt >= 0.1.0, templates >= 0.1.0, stopwatch >= 0.1.0, lazy_rest >= 0.2.2"
