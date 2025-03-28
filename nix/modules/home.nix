{config, ...}: let
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  home.username = "toxicdefender404";
  home.homeDirectory = "/home/toxicdefender404";

  home.file = {
    ".librewolf".source = link "${config.home.homeDirectory}/Sync/nix/config/librewolf";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/toxicdefender404/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
