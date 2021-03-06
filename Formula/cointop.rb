class Cointop < Formula
  desc "Interactive terminal based UI application for tracking cryptocurrencies"
  homepage "https://cointop.sh"
  url "https://github.com/miguelmota/cointop/archive/1.1.4.tar.gz"
  sha256 "269ed89b28a01ffa0712968f57369b104e93affe26e346052b0f3ab0cd498306"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "21feaa71a82a78c005d76af760087d309b954a513e0ee2a7455585cbe1eb7e6a" => :mojave
    sha256 "ef142d85b9d2c6af4f9f463157cfda38df76d81b82ea8a0157bff3414c1c4b9d" => :high_sierra
    sha256 "fd3a7e27039906da70ac9f034090a20240248074ed7bc50a1961a76f81010df8" => :sierra
    sha256 "30aae3981f0d4edb7a736d45cd23d6193af658d51991828081d4a9f7d93d34ec" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    src = buildpath/"src/github.com/miguelmota/cointop"
    src.install buildpath.children
    src.cd do
      system "go", "build", "-o", bin/"cointop"
      prefix.install_metafiles
    end
  end

  test do
    system bin/"cointop", "-test"
  end
end
