class Ledger < Formula
  desc "Command-line, double-entry accounting tool"
  homepage "https://ledger-cli.org/"
  url "https://github.com/ledger/ledger/archive/3.1.2.tar.gz"
  sha256 "3ecebe00e8135246e5437e4364bb7a38869fad7c3250b849cf8c18ca2628182e"
  revision 1
  head "https://github.com/ledger/ledger.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "2683f4bc536528f174307e20ccaa005d6acc86cd8bad1d40dc5b139b6c8b780e" => :mojave
    sha256 "665ec36ed864b27bfebcbb5b2e38f9286b8eb2ab5c27ff550b6a315373465ad0" => :high_sierra
    sha256 "07a870d7fd711329e5f5ea79f94b80ee21c81da3b97041c024aeca993d7d857c" => :sierra
    sha256 "9494361f07972f00dee91bd0295ba44211a18d06d4cb7577442e1bc6aec5f313" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "boost-python"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "python@2"
  depends_on "groff" unless OS.mac?

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j1" if ENV["CIRCLECI"]

    ENV.cxx11

    # Fix for https://github.com/ledger/ledger/pull/1760
    # Remove in next version
    inreplace "doc/ledger3.texi", "Getting help, ,",
                                "Getting help, Third-Party Ledger Tutorials,"

    args = %W[
      --jobs=#{ENV.make_jobs}
      --output=build
      --prefix=#{prefix}
      --boost=#{Formula["boost"].opt_prefix}
      --python
      --
      -DBUILD_DOCS=1
      -DBUILD_WEB_DOCS=1
      -DUSE_PYTHON27_COMPONENT=1
    ]
    system "./acprep", "opt", "make", *args
    system "./acprep", "opt", "make", "doc", *args
    system "./acprep", "opt", "make", "install", *args

    (pkgshare/"examples").install Dir["test/input/*.dat"]
    pkgshare.install "contrib"
    pkgshare.install "python/demo.py"
    elisp.install Dir["lisp/*.el", "lisp/*.elc"]
    bash_completion.install pkgshare/"contrib/ledger-completion.bash"
  end

  test do
    balance = testpath/"output"
    system bin/"ledger",
      "--args-only",
      "--file", "#{pkgshare}/examples/sample.dat",
      "--output", balance,
      "balance", "--collapse", "equity"
    assert_equal "          $-2,500.00  Equity", balance.read.chomp
    assert_equal 0, $CHILD_STATUS.exitstatus

    system "python", pkgshare/"demo.py"
  end
end
