{ pkgs, agentPackages, ... }:
with pkgs;
let
  # Matches jwiegley/nix-config's optAgent: a package sourced from
  # agentPackages (the numtide/llm-agents.nix flake) may not exist for
  # every system/revision, so degrade to an empty list instead of an
  # eval failure if it's missing.
  optAgent = name: if agentPackages ? ${name} then [ agentPackages.${name} ] else [ ];

  # pdf-tools' epdfinfo server, built by Nix against nixpkgs' poppler.
  # The Elisp side still comes from MELPA (package.el); pdf-info finds this
  # binary via `executable-find` before trying its own copy. Without it,
  # pdf-tools' autobuild runs `brew install poppler ...`, and the resulting
  # binary breaks on the next darwin-rebuild because homebrew.onActivation
  # .cleanup = "uninstall" removes those undeclared formulae.
  #
  # Built standalone from pdf-tools' server/ directory rather than taken
  # from emacsPackages.pdf-tools: our overlay replaces `emacs`, so that
  # package would be byte/native-compiled against emacs-head locally and
  # rebuilt on every emacs-src bump, just to extract this one C binary.
  epdfinfo = stdenv.mkDerivation {
    pname = "epdfinfo";
    inherit (emacsPackages.pdf-tools) version src;
    sourceRoot = "source/server";
    nativeBuildInputs = [ autoreconfHook pkg-config ];
    buildInputs = [ poppler libpng zlib ];
    installPhase = ''
      install -Dm755 epdfinfo $out/bin/epdfinfo
    '';
  };
in
{
  # Organized the way jwiegley/nix-config does it: one list, banner-commented
  # by theme, rather than one undifferentiated dump.
  package-list = [

    # ── Search & Text Processing ─────────────────────────────────────
    ripgrep
    fd
    pandoc

    # ── Spelling ──────────────────────────────────────────────────────
    aspell
    aspellDicts.en

    # ── Shell/Script Linting ───────────────────────────────────────────
    shellcheck

    # ── Build Tools ─────────────────────────────────────────────────────
    cmake
    # vterm's CMake build looks for `glibtool` specifically on Darwin
    # (Apple's own /usr/bin/libtool is a different, incompatible tool).
    # glibtool is nixpkgs' GNU libtool built with --program-prefix=g,
    # matching Homebrew's naming convention for exactly this reason.
    glibtool
    nodejs

    # ── Documents ─────────────────────────────────────────────────────
    epdfinfo

    # ── Accounting ────────────────────────────────────────────────────
    ledger

    # ── Encryption ────────────────────────────────────────────────────
    gnupg
  ]
  # ── Git Tools ────────────────────────────────────────────────────
  ++ [
    gh
  ]
  # ── AI Agents ──────────────────────────────────────────────────────
  ++ optAgent "claude-code"
  ++ optAgent "codex";
}
