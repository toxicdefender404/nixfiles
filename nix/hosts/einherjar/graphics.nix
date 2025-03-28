{
  config,
  pkgs,
  ...
}: {
  systemd.services.supergfxd.path = [pkgs.pciutils];
  environment.systemPackages = [pkgs.supergfxctl-plasmoid];

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
    power-profiles-daemon.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  boot.blacklistedKernelModules = ["nouveau"];
  services.xserver.videoDrivers = ["modesetting" "nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    dynamicBoost.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement = {
      enable = true;
      # Fine-grained power management. Turns off GPU when not in use.
      finegrained = false;
    };

    open = false;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true;
      # get values via nix shell nixpkgs#pciutils -c lspci -d ::03xx
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
