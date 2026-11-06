class Tunlite < Formula
  desc "Named SSH connections managed by native operating-system services"
  homepage "https://github.com/tunlite/tunlite"
  version "1.0.0-preview.1"
  license "MIT"
  revision 2

  on_macos do
    on_intel do
      url "https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_macos.tar.gz"
      sha256 "c29385423f7edea6fbce09667238255c664732abb8368773abc374e8da9dbb67"
    end

    on_arm do
      url "https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_macos.tar.gz"
      sha256 "c29385423f7edea6fbce09667238255c664732abb8368773abc374e8da9dbb67"
    end
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

  resource "use-tunlite" do
    url "https://raw.githubusercontent.com/tunlite/tunlite/v1.0.0-preview.1/skill/use-tunlite/SKILL.md", using: :nounzip
    version "1.0.0-preview.1"
    sha256 "d65a6048466713f45d3177868e90b59d3e5a8066784f3135e0731c1f7767941e"
  end

  deny_network_access! :test

  def install
    bin.install "tunlite"
    if File.file?("skills/use-tunlite/SKILL.md")
      (share/"tunlite/skills").install "skills/use-tunlite"
    else
      resource("use-tunlite").stage do
        (share/"tunlite/skills/use-tunlite").install "SKILL.md"
      end
    end
  end

  def caveats
    <<~EOS
      The matching use-tunlite Agent Skill is installed at:
        #{opt_share}/tunlite/skills/use-tunlite

      To activate it, copy this prompt into your Agent:
        Install the use-tunlite Skill from "#{opt_share}/tunlite/skills/use-tunlite" and enable it for Tunlite tasks.

      Homebrew does not modify Agent configuration. After upgrading, refresh any
      Skill copy installed in your Agent; use this stable path if it supports links.
    EOS
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

    skill = share/"tunlite/skills/use-tunlite/SKILL.md"
    assert_path_exists skill
    assert_predicate skill, :readable?
    assert_match(/\A---\nname: use-tunlite\n/, skill.read)
    assert_match "<!-- tunlite-contract\nprotocolVersion: 1\n", skill.read
    assert_match (opt_share/"tunlite/skills/use-tunlite").to_s, caveats
    assert_match "Install the use-tunlite Skill from", caveats
  end
end
