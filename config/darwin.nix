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
}
