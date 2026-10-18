{
  pkgs,
  config,
  username,
  agentPackages,
  ...
}@args:

let
  packages = import ./packages.nix args;
in
{
  imports = [ ./git.nix ];

  # nix-darwin's programs.zsh.enable (config/darwin.nix) only sets zsh as the
  # system default shell -- it doesn't hook home-manager's session variables
  # (home.sessionVariables, e.g. ASPELL_CONF/EDITOR/CLICOLOR below) into shell
  # startup. Without home-manager's own programs.zsh managing ~/.zshenv,
  # nothing sources /etc/profiles/per-user/${username}/etc/profile.d/hm-session-vars.sh,
  # so those variables are generated but never actually exported anywhere.
  programs.zsh.enable = true;

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  # Package list lives in its own file (packages.nix), matching
  # jwiegley/nix-config's structure, rather than inlined here.
  home.packages = packages.package-list;

  # Homebrew's own bin dirs, so brew-installed binaries are on PATH without
  # needing an imperative `eval "$(brew shellenv)"` in ~/.zprofile -- which
  # home-manager would overwrite anyway, since it manages that file once
  # programs.zsh.enable is on. Matches jwiegley/nix-config's config/johnw.nix
  # (home.sessionPath's "/opt/homebrew/bin" entry).
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    # Where `npm install -g` puts its binaries; see NPM_CONFIG_PREFIX below.
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  home.sessionVariables = {
    EDITOR = "emacsclient";
    CLICOLOR = 1;
    # aspell and aspellDicts.en are separate Nix packages that don't know
    # about each other by default; point aspell at an explicit config file
    # that wires the dictionary in, or Flyspell fails with "No word lists
    # can be found for the language en_US". Matches jwiegley/nix-config's
    # config/johnw.nix.
    ASPELL_CONF = "conf ${config.xdg.configHome}/aspell/config;";
    # npm's default global prefix is node's own install prefix, which for
    # nixpkgs' nodejs is a read-only /nix/store path, so `npm install -g`
    # fails with EACCES. Redirect it to a writable dir in $HOME. Set via env
    # rather than a home-manager-managed ~/.npmrc so that file stays
    # writable for `npm login` / `npm config set`.
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };

  xdg.configFile."aspell/config".text = ''
    local-data-dir ${pkgs.aspell}/lib/aspell
    data-dir ${pkgs.aspellDicts.en}/lib/aspell
    personal ${config.xdg.configHome}/aspell/en_US.personal
    repl ${config.xdg.configHome}/aspell/en_US.repl
  '';

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
    };
  };

  programs.uv.enable = true;
}
