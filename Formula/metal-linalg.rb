# metal-linalg, from the tap c0rmac/metal-linalg:
#
#   brew tap c0rmac/metal-linalg
#   brew trust c0rmac/metal-linalg
#   brew install metal-linalg
#
# Building from source does not need the Metal shader compiler: the build
# uses the metallibs committed under shaders/prebuilt when it is missing,
# which it is in Homebrew's build environment.
#
# `url` and `sha256` are set by metal-linalg's Release workflow on every
# release; `brew install --HEAD metal-linalg` builds the main branch instead.
class MetalLinalg < Formula
  desc "QR, symmetric eigendecomposition and SVD on Apple GPUs, for MLX"
  homepage "https://github.com/c0rmac/metal-linalg"
  url "https://github.com/c0rmac/metal-linalg/archive/refs/tags/v2.17.0.tar.gz"
  sha256 "1609316f485f4ffa7584e2c6286757c8c406bc0b19992f3f8f4fb8924ffdd762"
  license "MIT"
  head "https://github.com/c0rmac/metal-linalg.git", branch: "main"

  depends_on "cmake" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "mlx"

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DMETAL_LINALG_SHARED=ON",
           "-DMETAL_LINALG_BUILD_TESTS=OFF",
           "-DCMAKE_INSTALL_NAME_DIR=#{opt_lib}",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <metal_linalg/metal_linalg.h>
      #include <cstdio>
      using namespace mlx::core;
      int main() {
        array a = random::normal({4, 16, 16});
        auto [q, r] = metal_linalg::qr_accelerated(a);
        auto [w, v] = metal_linalg::eigh_accelerated(add(a, transpose(a, {0, 2, 1})));
        auto [u, s, vt] = metal_linalg::svd_accelerated(a);
        eval({q, r, w, v, u, s, vt});
        array e = max(abs(subtract(matmul(q, r), a)));
        eval({e});
        std::printf("%s %.1e\\n", metal_linalg::device_name(), e.item<float>());
        return e.item<float>() < 1e-4f ? 0 : 1;
      }
    CPP
    mlx = Formula["mlx"]
    system ENV.cxx, "-std=c++20", "test.cpp", "-o", "test",
           "-I#{include}", "-I#{mlx.opt_include}",
           "-L#{lib}", "-lmetal_linalg", "-L#{mlx.opt_lib}", "-lmlx",
           "-Wl,-rpath,#{lib}", "-Wl,-rpath,#{mlx.opt_lib}"
    system "./test"
  end
end
