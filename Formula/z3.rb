class Z3 < Formula
  desc "High-performance theorem prover"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/Z3Prover/z3/archive/z3-4.8.4.tar.gz"
  sha256 "5a18fe616c2a30b56e5b2f5b9f03f405cdf2435711517ff70b076a01396ef601"
  revision 2
  head "https://github.com/Z3Prover/z3.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    rebuild 1
    sha256 "c40462a152d29d1a17828b42fe5aba6a6584d955ff668f95a77e2bbfeb4d9827" => :mojave
    sha256 "9f4ea1d8faf70a2510eeb93648c378067efd1b7b26e31dd26d4454eb5c503392" => :high_sierra
    sha256 "9930015dd6c3a7c18aca7284aa145ea2b9b37c5297c650ab8584912c56593a35" => :sierra
    sha256 "46d0ae7ad6557dec6266594c826a65e6556061fda499fbad56daad5ef4e9d9f5" => :x86_64_linux
  end

  depends_on "python"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j4" if ENV["CIRCLECI"]

    xy = Language::Python.major_minor_version "python3"
    system "python3", "scripts/mk_make.py",
                      "--prefix=#{prefix}",
                      "--python",
                      "--pypkgdir=#{lib}/python#{xy}/site-packages",
                      "--staticlib"

    cd "build" do
      system "make"
      system "make", "install"
    end

    system "make", "-C", "contrib/qprofdiff"
    bin.install "contrib/qprofdiff/qprofdiff"

    pkgshare.install "examples"
  end

  test do
    system ENV.cc, pkgshare/"examples/c/test_capi.c",
      "-I#{include}", "-L#{lib}", "-lz3", "-o", testpath/"test"
    system "./test"
  end
end
