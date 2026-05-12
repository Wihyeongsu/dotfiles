{ config, pkgs, ... }:

{
# Home Manager needs a bit of information about you and the paths it should
# manage.
  home.username = "h0su";
  home.homeDirectory = "/home/h0su";

# This value determines the Home Manager release that your configuration is
# compatible with. This helps avoid breakage when a new Home Manager release
# introduces backwards incompatible changes.
#
# You should not change this value, even if you update Home Manager. If you do
# want to update the value, then make sure to first check the Home Manager
# release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

# The home.packages option allows you to install Nix packages into your
# environment.
    home.packages = with pkgs; [
      ripgrep
      docker
      oh-my-zsh
      nil
      vscode
      podman
      podman-tui
      nodejs_25
      opencode
      github-copilot-cli
      nushell
      carapace
      starship
    ];

# Home Manager is pretty good at managing dotfiles. The primary way to manage
# plain files is through 'home.file'.
  home.file = {
# # Building this configuration will create a copy of 'dotfiles/screenrc' in
# # the Nix store. Activating the configuration will then make '~/.screenrc' a
# # symlink to the Nix store copy.
# ".screenrc".source = dotfiles/screenrc;

# # You can also set the file content immediately.
# ".gradle/gradle.properties".text = ''
#   org.gradle.console=verbose
#   org.gradle.daemon.idletimeout=3600000
# '';
      # ".oh-my-zsh/custom/themes/lcars.zsh-theme".source = ../../.oh-my-zsh/custom/themes/lcars.zsh-theme;
  };

# Home Manager can also manage your environment variables through
# 'home.sessionVariables'. These will be explicitly sourced when using a
# shell provided by Home Manager. If you don't want to manage your shell
# through Home Manager then you have to manually source 'hm-session-vars.sh'
# located at either

#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
# or
#
#  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  /etc/profiles/per-user/h0su/etc/profile.d/hm-session-vars.sh
#
  home.sessionVariables = {
    EDITOR = "nvim";

  };

  systemd.user.services.vscode-tunnel = {
    Unit = {
      Description = "VSCode Tunnel";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.vscode}/bin/code tunnel --accept-server-license-terms";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

# Let Home Manager install and manage itself.
  programs = {
    home-manager = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    vscode = {
        enable = true;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [];
          userSettings = {};
        };
      };
    git = {
      enable = true;
      settings = {
        user = {
          name  = "Wihyeongsu";
          email = "wibrother2@gmail.com";
        };
        init.defaultBranch = "main";
        alias = {
          com = "commit";
          ch = "checkout";
          s = "status";
        };
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # plugins = [
      #   {
      #     name = "spaceship";
      #     src = pkgs.spaceship-prompt;
      #     file = "lib/spaceship-prompt/spaceship.zsh";
      #   }
      # ];
      oh-my-zsh = { # "ohMyZsh" without Home Manager
        enable = true;
        plugins = [ 
                    "git"
                    "docker"
                    "systemd"
                    "firewalld"
                    "git-auto-fetch"
                    "rsync"
                    "battery"
                    ];
        custom = "$HOME/.oh-my-zsh/custom";
        theme = "lcars";
      };
      shellAliases = {
        ll = "ls -la";
        hmc = "nvim ~/.config/home-manager";
        hms = "home-manager switch --flake ~/.config/home-manager";
        nv = "nvim";
        c = "clear";
        ff = "fastfetch";
      };
      history.size = 10000;
    };

  };
}
