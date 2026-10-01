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
brew install --HEAD metal-linalg
```

`--HEAD` builds the latest code from metal-linalg's `main` branch. It is
needed until the first release is tagged; after that, `brew install
metal-linalg` installs the latest release.

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
brew upgrade --fetch-HEAD metal-linalg    # a --HEAD install: rebuild from the latest main
brew upgrade metal-linalg                 # a release install
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

Until the first release there is only the `--HEAD` build, which Homebrew does
not install as a dependency: install metal-linalg with `--HEAD` first, as
above, and the dependent formula finds it.

Homebrew builds have no network access, so a project that otherwise fetches
metal-linalg's source with CMake's `FetchContent` must use the installed
package (`find_package(MetalLinalg)`) when built by its formula.

## Releasing a new version

1. Tag the release in `c0rmac/metal-linalg`, e.g. `v2.0.0`.
2. In `Formula/metal-linalg.rb`, add the stable source above `head`: the
   tag's tarball and its checksum.

   ```ruby
   url "https://github.com/c0rmac/metal-linalg/archive/refs/tags/v2.0.0.tar.gz"
   sha256 "..."
   ```

   ```bash
   curl -sL https://github.com/c0rmac/metal-linalg/archive/refs/tags/v2.0.0.tar.gz | shasum -a 256
   ```

   For later releases, change both lines.
3. Check it builds, passes its test and is well-formed:

   ```bash
   brew install --build-from-source c0rmac/metal-linalg/metal-linalg
   brew test c0rmac/metal-linalg/metal-linalg
   brew audit --strict c0rmac/metal-linalg/metal-linalg
   ```

4. Commit and push this repository. After the first release, drop `--HEAD`
   from the install instructions here and in metal-linalg's README.
