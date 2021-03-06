class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.8.26.tar.gz"
  sha256 "13f79098d63d6a89880c5563bcaf470fc7f1f6b5cc8711b4f04bc78bd2a5563b"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "fad1df7622e29afb1f6e0d074e2730bb6e79700319a0e299bd5570c423c906de" => :mojave
    sha256 "123cc5316d7dd8f9b9b79f297bae2403ea06bb204daca04dec859c771c9406e3" => :high_sierra
    sha256 "cddc04fe913fa53ccdd1afe67707afd7a81c3f62c794fef9a3f22462a0938faa" => :sierra
    sha256 "1313b0147e255f300ef4e7576e7e33dea67ab3a9bc5d7e0402995690edf3f4c6" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV.O0 unless OS.mac? # See https://github.com/golang/go/issues/26487
    system "make", "all"
    bin.install Dir["build/bin/*"]
  end

  test do
    (testpath/"genesis.json").write <<~EOS
      {
        "config": {
          "homesteadBlock": 10
        },
        "nonce": "0",
        "difficulty": "0x20000",
        "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "timestamp": "0x00",
        "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "extraData": "0x",
        "gasLimit": "0x2FEFD8",
        "alloc": {}
      }
    EOS
    system "#{bin}/geth", "--datadir", "testchain", "init", "genesis.json"
    assert_predicate testpath/"testchain/geth/chaindata/000001.log", :exist?,
                     "Failed to create log file"
  end
end
