# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class ZenBrowser < Formula
  desc "Welcome to a calmer internet"
  homepage "https://zen-browser.app"
  arch = Hardware::CPU.intel? ? "x86_64" : "aarch64"
  version_str = "1.21.7b"
  main_sha256 = "fcc3a1fd55e854bbe7daeb77bca00506792b1977ca16e8670f9923bc273bf370"
  metadata_sha256 = "e6abf60128d45a4dda0cfbc05a6919987a2e4c78ba97fc181e3098399a08ef85"
  url "https://github.com/zen-browser/desktop/releases/download/#{version_str}/zen.linux-#{arch}.tar.xz"
  sha256 main_sha256
  license "MPL-2.0"


  depends_on :linux

  livecheck do
    url "https://github.com/zen-browser/desktop/releases"
    strategy :github_latest
  end

  resource "metadata" do
    url "https://github.com/zen-browser/flatpak/releases/download/#{version_str}/archive.tar"
    sha256 metadata_sha256
  end

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
    # system "./configure", "--disable-silent-rules", *std_configure_args
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    libexec.install Dir["*"]
    bin.install_symlink libexec/"zen"

    resource("metadata").stage do
      # The Flatpak App ID used as the filename
      app_id = "app.zen_browser.zen"

      # Install the official .desktop file directly into share/applications
      (share/"applications").install "#{app_id}.desktop"

      # Install the scalable SVG icon into the standard Linux hicolor theme directory
      (share/"icons/hicolor/scalable/apps").install "icons/#{app_id}.svg"

      # Install the AppStream metainfo file (helps software centers like GNOME Software recognize it)
      #(share/"metainfo").install "#{app_id}.metainfo.xml"
    end

    inreplace share/"applications/app.zen_browser.zen.desktop" do |s|
      # 1. Direct the shortcut to explicitly launch our Homebrew binary path
      s.gsub!(/^Exec=.*$/, "Exec=#{bin}/zen %u")

      # 2. CRITICAL: Turn off DBus activation so GNOME stops launching the Flatpak
      #s.gsub!(/^DBusActivatable=true$/, "DBusActivatable=false")

      # 3. OPTIONAL: Appends "(Homebrew)" to the app grid name so you can verify it works
      s.gsub!(/^Name=Zen Browser$/, "Name=Zen Browser (Homebrew)")
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test zen-browser`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
