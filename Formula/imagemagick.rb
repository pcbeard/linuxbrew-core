class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/ImageMagick-7.0.8-34.tar.xz"
  mirror "https://www.imagemagick.org/download/ImageMagick-7.0.8-34.tar.xz"
  sha256 "0456bb9617144619f56103414e13ae0bbfa63af68a60e5967a41fe69e7fb57bf"
  head "https://github.com/ImageMagick/ImageMagick.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "7d7caa1ce80410c3830a96350eb1e5e7d7c497b1e321683081fecad4121e2853" => :mojave
    sha256 "06dfd080e939b04ef30cd75aaf3d7a096d9bff3a128d3ed5f4a5471631097a00" => :high_sierra
    sha256 "2d470130f71df55f3ca1b76047ac7c98ebfd3f9617b987a614a3032fb4719128" => :sierra
    sha256 "fd83bd7afb7063c9b2e1c56d7b22339630dcae13d306c6d3b22b768a733deb6e" => :x86_64_linux
  end

  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libheif"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openexr"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"

  depends_on "bzip2" unless OS.mac?
  depends_on "linuxbrew/xorg/xorg" unless OS.mac?
  depends_on "libxml2" unless OS.mac?

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-openjp2
      --with-openexr
      --with-webp=yes
      --with-heic=yes
      --without-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
      --enable-openmp
      ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp
      ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp
      LDFLAGS=-lomp
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
