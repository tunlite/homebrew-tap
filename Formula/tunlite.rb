class Tunlite < Formula
  desc "Named SSH connections managed by native operating-system services"
  homepage "https://github.com/tunlite/tunlite"
  version "1.0.0-preview.1"
  license "MIT"
  revision 1

  on_macos do
    url "https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_macos.tar.gz"
    sha256 "c29385423f7edea6fbce09667238255c664732abb8368773abc374e8da9dbb67"
  end

  on_linux do
    on_intel do
      url "https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_linux_x64.tar.gz"
      sha256 "b174be466be6bb75a8119058df4f35629efb596f1732abcb2218920b71c90a7f"
    end

    on_arm do
      url "https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_linux_arm64.tar.gz"
      sha256 "3ec874d994f85ef22fb8b03a24ef1b132bde39d27bdf968a505a0af03fa0a1e8"
    end
  end

  deny_network_access! :test

  def install
    bin.install "tunlite"
  end

  test do
    ENV["TUNLITE_HOME"] = testpath/"tunlite"

    assert_equal version.to_s, shell_output("#{bin}/tunlite version").strip
    info = JSON.parse(shell_output("#{bin}/tunlite version --json --non-interactive"))
    assert_equal "succeeded", info.fetch("outcome")
    assert_equal 1, info.fetch("protocolVersion")
    assert_equal version.to_s, info.fetch("version")

    result = JSON.parse(shell_output("#{bin}/tunlite list --json --non-interactive"))
    assert_equal "succeeded", result.fetch("outcome")
    assert_equal [], result.fetch("results")
    refute_path_exists testpath/"tunlite"
  end
end
