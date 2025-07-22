{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix garbage collection
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "02:45" ];
    };
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    hostName = "nixpad";
    networkmanager.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # xdg desktop portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Flatpak repository setup
  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub repository";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
  };

  # Flatpak package installations
  systemd.services.flatpak-install-zen = {
    description = "Install Zen Browser from Flathub";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-add-flathub.service" ];
    requires = [ "flatpak-add-flathub.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak install -y flathub io.github.zen_browser.zen";
    };
  };

  systemd.services.flatpak-install-sober = {
    description = "Install Sober from Flathub";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-add-flathub.service" ];
    requires = [ "flatpak-add-flathub.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober";
    };
  };

  systemd.services.flatpak-install-zed = {
    description = "Install Zed from Flathub";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-add-flathub.service" ];
    requires = [ "flatpak-add-flathub.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak install -y flathub dev.zed.Zed";
    };
  };

  # Disable power-profiles-daemon
  services.power-profiles-daemon.enable = false;

  # Timezone and locale
  time.timeZone = "Asia/Qatar";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      LC_CTYPE = "en_US.utf8"; # Required by dmenu
    };
  };

  # X server and i3 window manager
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
      ];
    };
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    displayManager.lightdm.enable = true;
  };

  #default session
  services.displayManager.defaultSession = "xfce+i3";

  # Additional services
  services = {
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    printing.enable = true; # CUPS for printing
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User configuration
  users.users.arslaana = {
    isNormalUser = true;
    description = "arslaana";
    extraGroups = [ "networkmanager" "wheel" "flatpak" ];
    packages = with pkgs; [
      brave
      xarchiver
      discord
      vscode
      alacritty
    ];
  };

  # Default shell
  users.defaultUserShell = pkgs.bash;

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    alacritty
    dmenu
    git
    fzf
    eza
    fastfetch
    networkmanagerapplet
    nitrogen
    pasystray
    picom
    polkit_gnome
    rofi
    neovim
    auto-cpufreq
    unrar
    unzip
    wget
    feh
    htop
  ];
  services.tumbler.enable = true;


  # enable picom as a service
  services.picom = {
    enable = true;
    inactiveOpacity = 0.95;
    vSync = true;
    fadeDelta = 4;
    activeOpacity = 1;
    backend = "glx";
    fade = true;
    shadow = true;
    settings = {
      blur = {
      method = "dual_kawase";
      background = true;
      strength = 5;
      };
     };
    };    
  
  # enable auto-cpufreq
  services.auto-cpufreq.enable = true;

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Additional programs
  programs = {
    thunar.enable = true;
    dconf.enable = true;
  };

  # Security
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Polkit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit GNOME Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # System state version
  system.stateVersion = "23.05";
}
