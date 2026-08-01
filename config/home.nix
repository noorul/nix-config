{
  pkgs,
  username,
  agentPackages,
  ...
}@args:

let
  packages = import ./packages.nix args;
in
{
  imports = [ ./git.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  # Package list lives in its own file (packages.nix), matching
  # jwiegley/nix-config's structure, rather than inlined here.
  home.packages = packages.package-list;

  # Nix-native replacement for the mactex Homebrew cask -- scheme-full is
  # the same scope as MacTeX itself, not a lighter substitute. Matches
  # jwiegley/nix-config's config/johnw.nix. Emits a deprecation warning
  # (texlive.combine -> texliveSmall.withPackages, removed in nixpkgs
  # 27.05) since home-manager hasn't migrated this module yet -- harmless
  # for now, revisit once upstream updates it.
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs) scheme-full texdoc latex2e-help-texinfo;
      pkgFilter = pkg: pkg.tlType == "run" || pkg.tlType == "bin" || pkg.pname == "latex2e-help-texinfo";
    };
  };
}
