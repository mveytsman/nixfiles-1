{ pkgs, ... }:

{
  # This setup for console-based login and automatic startx works with:
  #   services.xserver.displayManager.startx.enable = true;
  #   services.xserver.desktopManager.default = "none";

  # TODO: exec xcalib -d :0 "${nixpkgs}/hardware/thinkpad-x1c-hdr.icm"
  home.file.".xinitrc".text = ''
    # Delegate to xsession config
    . ~/.xsession
  '';

  home.file.".bash_profile".text = ''
    if [[ -f ~/.bashrc ]] ; then
      . ~/.bashrc
    fi
    if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
      exec ssh-agent startx
    fi
  '';

  gtk = {
    enable = true;
    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    iconTheme = {
      package = pkgs.tango-icon-theme;
      name = "Tango";
    };
  };

  xsession = {
    enable = true;

    # dbus-launch manages cross-process communication (required for GTK systray icons, etc).
    # FIXME: Is dbus-launch necessary now that it's part of xsession?
    windowManager.command = "dbus-launch --exit-with-x11 i3";

    pointerCursor = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 32;
    };
  };

  # Using a compositor fixes tearing on Nvidia and DRI3 freezing on Intel
  services.picom = {
    enable = true;
    backend = "glx";
    #vSync = true; # Probably don't want this unless you have tearing issues
  };

  services.xidlehook = {
    enable = false; # TODO: Switch from i3 config of xss-lock to this
    not-when-fullscreen = true;
  };

  services.network-manager-applet.enable = true;

  services.redshift = {
    enable = true;
    #provider = "geoclue2";
    provider = "manual";
    latitude = "43.65";
    longitude = "-79.38";
    temperature.day = 5700;
    temperature.night = 3500;
    settings.redshift.brightness-day = "1.0";
    settings.redshift.brightness-night = "0.7";
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        geometry = "600x5-30+20";
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        font = "DejaVu Sans Mono 10";
        format = "<b>%s</b>\n%b";
        icon_position = "left";
        max_icon_size = 48;
        indicate_hidden = "yes";
        shrink = "no";
        frame_color = "#aaaaaa";
        markup = "full";
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "yes";

        dmenu = "rofi -dmenu -p Dunst";
        browser = "xdg-open";
      };
      shortcuts = {
        close = "ctrl+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
    };
  };

  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 14";
    theme = "Monokai";
    package = pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; };
    extraConfig = {
      combi-mode = "window,drun,calc";
    };
  };
}
