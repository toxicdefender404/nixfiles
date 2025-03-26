# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {inherit inputs;};
    users = {
      toxicdefender404 = import ../../modules/home.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "einherjar";
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/London";

  # Select internationalisation properties
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.enable = false;
  services.displayManager.sddm.wayland.enable = true;

  # Enable the KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use. (apparently experimental)
    powerManagement.finegrained = false;

    # whether to use nvidia open source kernel module (apparently unstable)
    open = false;

    # nvidia-settings command.
    nvidiaSettings = true;

    # specify driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      #integrated graphics by default, run nvidia-offload to use dedicated
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # get values via nix shell nixpkgs#pciutils -c lspci -d ::03xx
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #enables printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.toxicdefender404 = {
    isNormalUser = true;
    description = "toxicdefender404";
    extraGroups = ["networkmanager" "wheel" "dialout" "users"];
    packages = with pkgs; [
      (prismlauncher.override
        {
          additionalLibs = [glfw3-minecraft];
          jdks = [
            graalvm-ce
          ];
        })
      syncthing
      obs-studio
      mpv
      unstable.vscode
      discord-ptb
      ventoy
      tor-browser
      terraria-server
      libreoffice
      tmux
      steamcmd
      qmk
      python39
      ungoogled-chromium
      tradingview
      static-web-server
      davinci-resolve
      kdePackages.kdeconnect-kde
      obsidian
      neovim
      qbittorrent
      llvmPackages_19.clang-unwrapped
      rustup
      xclicker
      signal-desktop
      cubiomes-viewer
      framesh
      brave
      protonvpn-gui
      waydroid
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "toxicdefender404";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  virtualisation.waydroid.enable = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["Hack" "JetBrainsMono"];})
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gparted
    wget
    fastfetch
    keepassxc
    nixd
    alacritty
    alejandra
    kate
    git
    git-credential-keepassxc
  ];

  services.dbus.packages = with pkgs; [xdg-desktop-portal-kde];
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-kde];
  };

  virtualisation.docker.enable = false;
  services.flatpak.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
