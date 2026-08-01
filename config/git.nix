{
  programs.git = {
    enable = true;
    ignores = [
      ".projectile"
      ".dir-locals.el"
      "settings.local.json"
    ];
    signing.format = null;
    settings = {
      user.name = "Noorul Islam K M";
      user.email = "noorul@noorul.com";
      github.user = "noorul";
    };
  };
}
