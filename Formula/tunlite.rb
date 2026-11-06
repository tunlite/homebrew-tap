class Tunlite < Formula
  desc "Named SSH connections managed by native operating-system services"
  homepage "https://github.com/tunlite/tunlite"
  url "https://github.com/tunlite/tunlite/archive/refs/tags/v1.0.0-preview.1.tar.gz"
  version "1.0.0-preview.1"
  sha256 "ceed905a07e3ce6915c009811789818ec697dacc471eadb63de57beaf97a9805"
  license "MIT"

  depends_on "go" => :build

  deny_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Homebrew releases before the fetch hook download modules during install.
    fetch unless respond_to?(:fetch_defined?)
    ENV["GOPROXY"] = "off"
    ldflags = "-X github.com/tunlite/tunlite/internal/cli.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/tunlite"
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
