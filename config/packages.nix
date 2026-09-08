{ pkgs, agentPackages, ... }:
with pkgs;
let
  # Matches jwiegley/nix-config's optAgent: a package sourced from
  # agentPackages (the numtide/llm-agents.nix flake) may not exist for
  # every system/revision, so degrade to an empty list instead of an
  # eval failure if it's missing.
  optAgent = name: if agentPackages ? ${name} then [ agentPackages.${name} ] else [ ];
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

    # ── Accounting ────────────────────────────────────────────────────
    ledger

    # ── Encryption ────────────────────────────────────────────────────
    gnupg
  ]
  # ── AI Agents ──────────────────────────────────────────────────────
  ++ optAgent "claude-code"
  ++ optAgent "codex";
}
