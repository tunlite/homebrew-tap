# Tunlite Homebrew tap

Install the published `1.0.0-preview.1` release from `tunlite/homebrew-tap`:

```sh
brew install tunlite/tap/tunlite
type -a tunlite
tunlite version --json
```

Homebrew downloads the official release archive for your platform, verifies its
pinned SHA-256, and installs the already compiled `tunlite` CLI. It does not install
Go or compile source, and the Formula has no build or runtime formula dependencies.
macOS uses the Universal 2 binary; Linux selects x86_64 or arm64. Follow Homebrew's
`brew shellenv` instructions to put its `bin` directory in `PATH`.

The matching `use-tunlite` Agent Skill is also installed under Homebrew's shared
package directory. Install, reinstall, and upgrade show its stable local path and
an activation prompt. To display the instructions again:

```sh
brew info tunlite/tap/tunlite
```

Copy the prompt shown there into your Agent, replacing nothing in the actual local
path. For example, an Intel Mac's default Homebrew prefix shows:

```text
Install the use-tunlite Skill from "/usr/local/opt/tunlite/share/tunlite/skills/use-tunlite" and enable it for Tunlite tasks.
```

Use the path printed on your machine: Apple Silicon and Linux prefixes differ.
Activation is optional and Agent-managed; Homebrew never edits Agent directories
or configuration. After an upgrade, ask your Agent to refresh any copied Skill.
An Agent that supports links may use the printed stable path instead. Removing
the Homebrew package removes its shared Skill, but any copies in an Agent remain
user-managed.

The system OpenSSH `ssh` executable must be available at runtime (or set
`TUNLITE_SSH` to its absolute path). Tunlite supports macOS 12+ with per-Connection
launchd user or system services; Homebrew itself may require a newer macOS release.
On Linux, persistent connections require a systemd user session; Linux system
scope is unsupported. Use `tunlite run` when a systemd user session is unavailable.
See the [upstream preview guide](https://github.com/tunlite/tunlite/blob/main/docs/V1_PREVIEW.md)
for platform validation limits, including unverified Apple Silicon hardware and
non-container Linux hosts.

There is no central `brew services` service. Installation and formula tests do not
create connections, edit SSH credentials/configuration, or start or stop tunnels.
Homebrew delivery does not provide Apple developer signing or notarization and is
not a guarantee against quarantine or enterprise policies.

## Upgrade and remove

```sh
brew update
brew upgrade tunlite/tap/tunlite
# To reinstall the current package when necessary:
brew reinstall tunlite/tap/tunlite
# To remove the CLI:
brew uninstall tunlite/tap/tunlite
```

Run `brew update` before retrying an installation from an older tapped checkout.
The binary-and-Skill package is revision `2` (`1.0.0-preview.1_2` in Homebrew), so
existing source-built or revision-1 packages upgrade without changing the application version.
This packaging change does not automatically remove Go installed by a previous
Formula; manage existing Go installations separately according to your needs.

Upgrade installs the version published in this tap. Removing the CLI does **not**
stop existing SSH services owned by launchd or systemd, nor remove declarations or
SSH files. To stop a Connection, use its explicit lifecycle commands before
removing the CLI.

Choose one installation channel. Run `type -a tunlite` to find older manual,
bootstrap, or Go-installed copies earlier in `PATH`; verify the selected executable
with `tunlite version --json`. Adjust `PATH` or remove only the exact old executable
after confirming its owner/channel. Do not use `brew link --overwrite` to replace
an unidentified copy. This formula does not migrate older dev service records.

## Maintain a release

1. Confirm the new published tag and its commit in the official
   [`tunlite/tunlite`](https://github.com/tunlite/tunlite) repository. Never move an
   existing release tag or replace its published assets silently.
2. Download `SHA256SUMS` and all three platform archives from that exact Release
   over HTTPS. For example:

   ```sh
   curl --fail --location --proto '=https' --tlsv1.2 \
     https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/SHA256SUMS \
     --output SHA256SUMS
   curl --fail --location --proto '=https' --tlsv1.2 \
     https://github.com/tunlite/tunlite/releases/download/v1.0.0-preview.1/tunlite_1.0.0-preview.1_macos.tar.gz \
     --output tunlite_1.0.0-preview.1_macos.tar.gz
   shasum -a 256 tunlite_1.0.0-preview.1_macos.tar.gz
   # Linux alternative: sha256sum tunlite_1.0.0-preview.1_macos.tar.gz
   ```

   Repeat for `linux_x64` and `linux_arm64`, compare every calculated checksum
   with `SHA256SUMS` and GitHub's asset metadata, and verify the Release Artifact
   Attestation as described upstream. A checksum pins downloaded bytes; it does
   not independently authenticate the publisher. Do not use a source archive digest.
3. Change all platform `url` and `sha256` values together with explicit `version`.
   Keep the full prerelease version explicit because Homebrew's URL parser can
   shorten it. Reset `revision` when the application version changes; increment it
   when packaging changes require reinstalling the same application version.
   Confirm each installed binary reports the exact version and update examples.
   Current immutable Preview.1 binary archives predate bundled Skills. Their
   matching Skill comes from the pinned `v1.0.0-preview.1` raw-GitHub resource,
   SHA-256 `d65a6048466713f45d3177868e90b59d3e5a8066784f3135e0731c1f7767941e`.
   Never change that fallback to `main`, `latest`, or a different release's Skill.
   Future archives contain `skills/use-tunlite/SKILL.md`; installation prefers
   that bundled directory. When advancing to such a release, verify the bundled
   Skill matches its canonical source and remove the legacy resource/fallback.
   Until then, update a fallback's tag and verified checksum together with the
   application version. Do not replace existing release assets to add the Skill.
4. Run `brew style tunlite/tap/tunlite`, `brew audit --strict tunlite/tap/tunlite`,
   `brew reinstall tunlite/tap/tunlite`, and
   `brew test tunlite/tap/tunlite` in a clean test environment. CI runs style,
   audit, a dependency check, binary installation, and isolated tests on macOS and Linux.

The built-in test checks plain and JSON versions plus read-only `list` against a
temporary `TUNLITE_HOME`, and asserts that it creates no configuration/state.
It also checks the actual installed Skill's frontmatter/contract and the stable
activation path/prompt in Homebrew caveats.
