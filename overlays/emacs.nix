# overlays/emacs.nix
# Purpose: Build Emacs from live upstream trunk (emacs-mirror/emacs) with
#          native compilation enabled. Unlike jwiegley/nix-config's
#          `emacsHEAD` (an -O0/--enable-checking debug build for Emacs core
#          development), this is a normal optimized build for daily use.
#          It does NOT rebuild any third-party Elisp packages as Nix
#          derivations -- package management is left to the user's own
#          dot-emacs config (straight.el/package.el) at runtime.
{ emacs-src }:
final: prev: {
  emacs =
    (prev.emacs31.override {
      withImageMagick = true;
      withNativeCompilation = true;
    }).overrideAttrs
      (attrs: {
        pname = "emacs-head";
        version = "31-git-${builtins.substring 0 8 (emacs-src.rev or "unknown")}";
        src = emacs-src;

        # withNativeCompilation sets NATIVE_FULL_AOT=1 by default, which
        # eagerly native-compiles every bundled .el file (hundreds of them,
        # including things like Org/Gnus/SES) during the build. Drop it so
        # only the preload set needed to bootstrap gets compiled now; the
        # rest natively compiles lazily on first use, same as a normal
        # from-source build.
        env = builtins.removeAttrs attrs.env [ "NATIVE_FULL_AOT" ];

        # Append, don't replace: the base attrs already carry patches
        # nixpkgs applies whenever withNativeCompilation is true (notably
        # native-comp-driver-options-30.patch, which bakes -B paths so
        # libgccjit can find gcc/ld/as at runtime without $PATH). Dropping
        # those causes "error invoking gcc driver" the first time a .el
        # file is natively compiled lazily. Basing on emacs31 (not emacs30)
        # matters here too: emacs30's patch list also carries CVE/compat
        # backports fetched for the exact 30.2 release tarball, which fail
        # to apply against our diverged emacs-31 branch checkout (hunks
        # don't match). emacs31 in nixpkgs carries no such extra patches.
        patches = attrs.patches ++ prev.lib.optionals prev.stdenv.isDarwin [ ./emacs/patches/nsthread.patch ];

        nativeBuildInputs = attrs.nativeBuildInputs ++ [
          prev.autoreconfHook
          prev.autoconf
          prev.automake
          prev.pkg-config
        ];

        # A raw git checkout has no generated configure script, and native
        # comp's extra load commands need more headerpad room to relink on
        # Darwin during fixup.
        preConfigure = ''
          sed -i -e 's/headerpad_extra=1000/headerpad_extra=2000/' configure.ac
          autoreconf
        '';
      });
}
