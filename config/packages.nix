{ pkgs, ... }:
with pkgs;
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
  ];
}
