{
  pkgs,
  username,
  ...
}:

{
  system.primaryUser = username;
  system.stateVersion = 5;

  # Using the classic multi-user Nix installer (not Determinate), so let
  # nix-darwin manage the daemon and nix.conf.
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # nix-darwin's app-linking activation script (symlinks .app bundles into
  # /Applications/Nix Apps, which Spotlight indexes) only scans
  # environment.systemPackages -- home.packages is invisible to it, so GUI
  # apps like Emacs.app must go here, not in home.nix.
  environment.systemPackages = [
    pkgs.emacs
  ];

  fonts.packages = with pkgs; [
    (iosevka-bin.override { variant = "SS04"; })
    (iosevka-bin.override { variant = "SS05"; })
    (iosevka-bin.override { variant = "Etoile"; })
  ];

  # Apps pinned to the Dock, in order. Nix-darwin's app-linking activation
  # script symlinks environment.systemPackages .app bundles into
  # /Applications/Nix Apps, hence the Emacs path below.
  system.defaults.dock.persistent-apps = [
    "/Applications/Nix Apps/Emacs.app"
    "/Applications/Firefox.app"
    "/Applications/Brave Browser.app"
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # The locked nix-darwin emits `--force-cleanup` for "uninstall", which
      # makes cleanup non-interactive without forcing package installation.
      # Do not add Homebrew Bundle's generic `--force`: it is forwarded to
      # installs as `--force/--overwrite`, replacing cask app bundles while
      # retaining their user state (which can corrupt in-app updater state).
      # Matches jwiegley/nix-config's config/darwin.nix.
      cleanup = "uninstall";
    };

    casks = [
      {
        name = "brave-browser";
        greedy = true;
      }
      {
        name = "firefox";
        greedy = true;
      }
      "docker-desktop"
      "vlc"
    ];
  };
}
