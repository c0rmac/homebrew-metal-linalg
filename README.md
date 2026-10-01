# homebrew-metal-linalg

The Homebrew tap for [metal-linalg](https://github.com/c0rmac/metal-linalg):
QR, symmetric eigendecomposition and SVD for batches of matrices on Apple
GPUs, for MLX and for plain float buffers.

- [Install](#install)
- [Use](#use)
- [Update and uninstall](#update-and-uninstall)
- [Depending on it from another formula](#depending-on-it-from-another-formula)
- [Releasing a new version](#releasing-a-new-version)

## Install

First tap this repository, so that Homebrew knows its formula:

```bash
brew tap c0rmac/metal-linalg
```

Then install metal-linalg:

```bash
brew install metal-linalg
```

That installs the latest release. `brew install --HEAD metal-linalg` builds
the latest code from metal-linalg's `main` branch instead.

Homebrew builds the library from source against its own `mlx`, which it
installs if needed; the build takes a minute or two. You need an Apple Silicon
Mac. No Metal shader compiler is needed: the compiled shaders ship in the
source tree and are embedded in the library.

## Use

The install provides `libmetal_linalg.dylib`, the headers under
`include/metal_linalg/`, and a CMake package:

```cmake
find_package(MetalLinalg REQUIRED)
target_link_libraries(my_app PRIVATE metal_linalg::metal_linalg)
```

That covers the C++ API on MLX arrays and the C API on plain buffers. The
[Python](https://github.com/c0rmac/metal-linalg#python) and
[Swift](https://github.com/c0rmac/metal-linalg#swift) packages are installed
with `pip` and Swift Package Manager instead, as metal-linalg's README describes.

## Update and uninstall

```bash
brew upgrade metal-linalg                 # to the latest release
brew upgrade --fetch-HEAD metal-linalg    # a --HEAD install: rebuild from the latest main
```

```bash
brew uninstall metal-linalg
brew untap c0rmac/metal-linalg
```

## Depending on it from another formula

A formula in another tap names it in full, which taps this one
automatically:

```ruby
depends_on "c0rmac/metal-linalg/metal-linalg"
```

Installing the dependent formula then installs metal-linalg automatically.

Homebrew builds have no network access, so a project that otherwise fetches
metal-linalg's source with CMake's `FetchContent` must use the installed
package (`find_package(MetalLinalg)`) when built by its formula.

## Releasing a new version

Nothing to do by hand: every update to metal-linalg's `main` branch that
changes the library publishes the next release, and its Release workflow
points `Formula/metal-linalg.rb` at the new tarball here (see metal-linalg's
[CONTRIBUTING.md](https://github.com/c0rmac/metal-linalg/blob/main/CONTRIBUTING.md#releases)).
That needs the secret `HOMEBREW_TAP_TOKEN` in metal-linalg's repository.

Without it, or to do it by hand, set the two lines to the release's tarball
and its checksum, then check and push:

```ruby
url "https://github.com/c0rmac/metal-linalg/archive/refs/tags/vX.Y.Z.tar.gz"
sha256 "..."
```

```bash
curl -sL https://github.com/c0rmac/metal-linalg/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
brew install --build-from-source c0rmac/metal-linalg/metal-linalg
brew test c0rmac/metal-linalg/metal-linalg
brew audit --strict c0rmac/metal-linalg/metal-linalg
```
