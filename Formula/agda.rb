require "language/haskell"

class Agda < Formula
  include Language::Haskell::Cabal

  desc "Dependently typed functional programming language"
  homepage "https://wiki.portal.chalmers.se/agda/"
  revision 1 unless OS.mac?

  stable do
    url "https://hackage.haskell.org/package/Agda-2.6.0/Agda-2.6.0.tar.gz"
    sha256 "bf71bc634a9fe40d717aae76b5b160dfd13a06365615e7822043e5d476c06fb8"

    resource "stdlib" do
      url "https://github.com/agda/agda-stdlib.git",
          :tag      => "v1.0.1",
          :revision => "442abf2b3418d4d488381a2f8ca4e99bbf8cfc8e"
    end
  end

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "33438627ea54c158323b499f5cff0acb0fcdb1498ed46709254182d3926c99a8" => :mojave
    sha256 "8e41acf29ecb3319d8ef00b77de952cfccafef87bf705bc32c1837073ce62acb" => :high_sierra
    sha256 "a49f81d7e0f49023a23067d0e496e2a387258d91820f23838f2ef804bea86714" => :sierra
    sha256 "cf80a2f7ae8947c8c7ec362bea17b08d3ce211a6682912a39c66e88d3d1ef0f7" => :x86_64_linux
  end

  head do
    url "https://github.com/agda/agda.git"

    resource "stdlib" do
      url "https://github.com/agda/agda-stdlib.git"
    end
  end

  depends_on "cabal-install" => [:build, :test]
  depends_on "emacs"
  depends_on "ghc"
  depends_on "zlib" unless OS.mac?

  def install
    # install Agda core
    install_cabal_package :using => ["alex", "happy", "cpphs"]

    resource("stdlib").stage lib/"agda"

    # generate the standard library's bytecode
    cd lib/"agda" do
      cabal_sandbox :home => buildpath, :keep_lib => true do
        cabal_install "--only-dependencies"
        cabal_install
        system "GenerateEverything"
      end
    end

    # generate the standard library's documentation and vim highlighting files
    cd lib/"agda" do
      system bin/"agda", "-i", ".", "-i", "src", "--html", "--vim", "README.agda"
    end

    # compile the included Emacs mode
    system bin/"agda-mode", "compile"
    elisp.install_symlink Dir["#{share}/*/Agda-#{version}/emacs-mode/*"]
  end

  def caveats; <<~EOS
    To use the Agda standard library by default:
      mkdir -p ~/.agda
      echo #{HOMEBREW_PREFIX}/lib/agda/standard-library.agda-lib >>~/.agda/libraries
      echo standard-library >>~/.agda/defaults
  EOS
  end

  test do
    simpletest = testpath/"SimpleTest.agda"
    simpletest.write <<~EOS
      module SimpleTest where

      data ℕ : Set where
        zero : ℕ
        suc  : ℕ → ℕ

      infixl 6 _+_
      _+_ : ℕ → ℕ → ℕ
      zero  + n = n
      suc m + n = suc (m + n)

      infix 4 _≡_
      data _≡_ {A : Set} (x : A) : A → Set where
        refl : x ≡ x

      cong : ∀ {A B : Set} (f : A → B) {x y} → x ≡ y → f x ≡ f y
      cong f refl = refl

      +-assoc : ∀ m n o → (m + n) + o ≡ m + (n + o)
      +-assoc zero    _ _ = refl
      +-assoc (suc m) n o = cong suc (+-assoc m n o)
    EOS

    stdlibtest = testpath/"StdlibTest.agda"
    stdlibtest.write <<~EOS
      module StdlibTest where

      open import Data.Nat
      open import Relation.Binary.PropositionalEquality

      +-assoc : ∀ m n o → (m + n) + o ≡ m + (n + o)
      +-assoc zero    _ _ = refl
      +-assoc (suc m) n o = cong suc (+-assoc m n o)
    EOS

    iotest = testpath/"IOTest.agda"
    iotest.write <<~EOS
      module IOTest where

      open import Agda.Builtin.IO
      open import Agda.Builtin.Unit

      postulate
        return : ∀ {A : Set} → A → IO A

      {-# COMPILE GHC return = \\_ -> return #-}

      main : _
      main = return tt
    EOS

    stdlibiotest = testpath/"StdlibIOTest.agda"
    stdlibiotest.write <<~EOS
      module StdlibIOTest where

      open import IO

      main : _
      main = run (putStr "Hello, world!")
    EOS

    # typecheck a simple module
    system bin/"agda", simpletest

    # typecheck a module that uses the standard library
    system bin/"agda", "-i", lib/"agda"/"src", stdlibtest

    # compile a simple module using the JS backend
    system bin/"agda", "--js", simpletest

    # test the GHC backend
    cabal_sandbox do
      cabal_install "text", "ieee754"
      dbpath = Dir["#{testpath}/.cabal-sandbox/*-packages.conf.d"].first
      dbopt = "--ghc-flag=-package-db=#{dbpath}"

      # compile and run a simple program
      system bin/"agda", "-c", dbopt, iotest
      assert_equal "", shell_output(testpath/"IOTest")

      # compile and run a program that uses the standard library
      system bin/"agda", "-c", "-i", lib/"agda"/"src", dbopt, stdlibiotest
      assert_equal "Hello, world!", shell_output(testpath/"StdlibIOTest")
    end
  end
end
