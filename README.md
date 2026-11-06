# Tunlite Homebrew tap

This repository is prepared for publication as `tunlite/homebrew-tap`. Once it is
public, install the fixed `1.0.0-preview.1` release with:

```sh
brew install tunlite/tap/tunlite
type -a tunlite
tunlite version --json
```

Homebrew verifies the pinned HTTPS source archive's SHA-256, installs Go as a build
dependency, and compiles only the `tunlite` CLI from `./cmd/tunlite`. Go is not a
runtime dependency. Follow Homebrew's `brew shellenv` instructions to put its `bin`
directory in `PATH`.

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
Source compilation normally avoids browser-download quarantine, but does not
provide Apple developer signing or notarization and is not a guarantee against
enterprise policies.

## Upgrade and remove

```sh
brew update
brew upgrade tunlite/tap/tunlite
brew uninstall tunlite/tap/tunlite
```

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
   existing release tag or replace its source archive silently.
2. Download the exact tag archive over HTTPS and calculate its checksum:

   ```sh
   curl --fail --location --proto '=https' --tlsv1.2 \
     https://github.com/tunlite/tunlite/archive/refs/tags/v1.0.0-preview.1.tar.gz \
     --output tunlite-source.tar.gz
   shasum -a 256 tunlite-source.tar.gz
   # Linux alternative: sha256sum tunlite-source.tar.gz
   ```

   Check its extracted contents against `git archive <tag>` from the verified
   official tag. The archive checksum pins the exact downloaded bytes; it does not
   independently authenticate the publisher. The initial tag peels to
   `2435b9496446d2b395aca87f26dd337552e204e6` and the archive checksum is
   `ceed905a07e3ce6915c009811789818ec697dacc471eadb63de57beaf97a9805`.
3. Change the Formula's `url` and `sha256` together. Homebrew derives `version`
   from the tag URL; the linker injects that version into
   `github.com/tunlite/tunlite/internal/cli.Version`. Update examples here if the
   fixed preview changes. Do not copy the prebuilt binary archive's checksum.
4. Run `brew style tunlite/tap/tunlite`, `brew audit --strict tunlite/tap/tunlite`,
   `brew reinstall --build-from-source tunlite/tap/tunlite`, and
   `brew test tunlite/tap/tunlite` in a clean test environment. CI runs style,
   audit, source installation, and isolated tests on macOS and Linux.

The built-in test checks plain and JSON versions plus read-only `list` against a
temporary `TUNLITE_HOME`, and asserts that it creates no configuration/state.
Current Homebrew downloads Go modules in the `fetch` phase before an offline
build; older releases without that hook download modules during installation.
Go's module checksum verification stays enabled in both cases.
