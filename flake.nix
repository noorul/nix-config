{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    formatter.aarch64-darwin =
      inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations.HPE-FHPMJKN7TQ = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        config.i18n.defaultLocale = "en_US.UTF-8";
        overlays = [ inputs.rust-overlay.overlays.default ];
      };
      modules = [
        { users.users.noorul.home = "/Users/noorul"; }
        ({ pkgs, ... }: {
          # here go the darwin preferences and config items
          services.nix-daemon.enable = true;
          programs.zsh.enable = true;
          environment.shells = [ pkgs.bash pkgs.zsh ];
          environment.variables = { LANG = "en_US.UTF-8"; };
          environment.systemPackages = with pkgs; [ git curl coreutils zoxide ];
          system.keyboard.enableKeyMapping = true;
          system.keyboard.remapCapsLockToControl = true;

          system.defaults.dock.persistent-apps = [
            "/Applications/Emacs.app"
            "/Applications/Firefox.app"
            "/Applications/Slack.app"
          ];

          # backwards compat; don't change
          system.stateVersion = 4;

          fonts.packages = with pkgs; [
            (iosevka-bin.override { variant = "SS04"; })
            (iosevka-bin.override { variant = "SS05"; })
            (iosevka-bin.override { variant = "Etoile"; })
          ];

          homebrew = {
            enable = true;
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            caskArgs.no_quarantine = true;
            global.brewfile = true;
            masApps = { };
            brews = [
              "autoconf"
              "bash-completion"
              "cmake"
              "dbus"
              "fontconfig"
              "gcc"
              "glib"
              "gnupg"
              "gnu-sed"
              "gnutls"
              "gmp"
              "harfbuzz"
              "imagemagick"
              "ispell"
              "jansson"
              "jq"
              "libev"
              "libffi"
              "libgccjit"
              "libiconv"
              "librsvg"
              "libtasn1"
              "libunistring"
              "libxml2"
              "mailutils"
              "make"
              {
                name = "maven";
                args = ["ignore-dependencies"];
              }
              "mosh"
              "ncurses"
              "pkg-config"
              "poetry"
              "ripgrep"
              "sqlite"
              "tree-sitter"
              "yq"
              "zlib"
            ];
            casks = [ "firefox" "google-chrome" "slack" "temurin@17" "docker" "brave-browser"];
          };
        })
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.noorul.imports = [
              ({ pkgs, ... }: {
                # Don't change this when you change package input. Leave it alone.
                home.stateVersion = "24.05";
                xdg.enable = true;
                # specify my home-manager configs
                home.packages = with pkgs; [
                  awscli2
                  curl
                  datree
                  fd
                  gnupg
                  go
                  hadolint
                  ispell
                  ledger
                  less
                  nil
                  nixfmt
                  ripgrep
                  (rust-bin.stable.latest.default.override {
                    extensions = [ "rust-analyzer" ];
                  })
                  shellcheck
                  shfmt
                  teleport_15
                  terraform
                  terraform-ls
                  trivy
                ];
                home.sessionVariables = {
                  CLICLOLOR = 1;
                  EDITOR = "emacsclient";
                };
                home.sessionPath =
                  [ "$HOME/.local/bin"
                    "$HOME/github.com/noorul/notebook/bin"
                    "$HOME/go/bin"
                    "/opt/homebrew/bin"
                    "/Applications/Emacs.app/Contents/MacOS/bin"
                  ];
                programs.bat.enable = true;
                programs.bat.config.theme = "TwoDark";
                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;
                programs.eza.enable = true;
                programs.git.enable = true;
                programs.zsh = {
                  enable = true;
                  enableCompletion = true;
                  autosuggestion.enable = true;
                  syntaxHighlighting.enable = true;
                  shellAliases = { ls = "ls --color=auto -F"; };
                  initExtra = ''
                    # Load secrets at shell startup
                    eval $(/opt/homebrew/bin/brew shellenv)
                    source /Users/noorul/.secrets
                  '';
                };
                programs.starship.enable = true;
                programs.starship.enableZshIntegration = true;
                programs.starship.settings = { command_timeout = 1800000; };
                programs.pyenv.enable = true;
                programs.pyenv.enableZshIntegration = true;
                home.file.".inputrc".text = ''
                  set show-all-if-ambiguous on
                  set completion-ignore-case on
                  set mark-directories on
                  set mark-symlinked-directories on
                  set match-hidden-files off
                  set visible-stats on
                '';
              })
            ];
          };
        }
      ];
    };
  };
}
