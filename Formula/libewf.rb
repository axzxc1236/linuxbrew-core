class Libewf < Formula
  desc "Library for support of the Expert Witness Compression Format"
  homepage "https://github.com/libyal/libewf"
  url "https://deb.debian.org/debian/pool/main/libe/libewf/libewf_20140608.orig.tar.gz"
  version "20140608"
  sha256 "d14030ce6122727935fbd676d0876808da1e112721f3cb108564a4d9bf73da71"
  revision 2

  bottle do
    cellar :any
    rebuild 1
    sha256 "7fe79d5c0cbbc77727528df3effaeb9e6cb85f041f3183aed7e288c572142bd4" => :mojave
    sha256 "a8598eb679b9a0abfb4ced4845cc21835101bcb47f909c0bf217a7211dc8d67a" => :high_sierra
    sha256 "9070532ca601a8d020a1de5ccca0e7613788afb696b4ffd7efcad652c7b77d7c" => :sierra
    sha256 "09e06f0c7edb1d2a75cbe4d063f39220e0f65b0cdc7cfe5391c58384373d61f5" => :x86_64_linux
  end

  head do
    url "https://github.com/libyal/libewf.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "openssl"
  unless OS.mac?
    depends_on "bzip2"
    depends_on "zlib"
  end

  def install
    # Workaround bug in gcc-5 that causes the following error:
    # undefined reference to `libuna_ ...
    ENV.append_to_cflags "-std=gnu89" if ENV.cc == "gcc-5"

    if build.head?
      system "./synclibs.sh"
      system "./autogen.sh"
    end

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-libfuse=no
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ewfinfo -V")
  end
end
