{ config, pkgs, lib, ... }:

{
  #####################
  # nix global config #
  #####################

  imports = [
    # Extra modules
    ./modules

    # Program config
    ./programs/zsh
    ./programs/tmux
  ];

  environment.systemPackages = with pkgs;
    [
      # GNU userland
      coreutils
      gnumake
      gnugrep
      gnused

      # System config
      mkpasswd

      # Dev tools
      git
      tig
      fzf
      ripgrep
      cmake
      ctags

      # Utilities
      tree
      findutils
      pstree
      htop
    ];

  environment.interactiveShellInit = ''
    alias df='df -hT'
  '';


  #################################
  # NixOS config for Raspberry Pi #
  #################################

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "usbhid" ];

  # Needed for the virtual console to work on the RPi 3, as the default of 16M
  # doesn't seem to be enough.  If X.org behaves weirdly (I only saw the
  # cursor) then try increasing this to 256M.  On a Raspberry Pi 4 with 4 GB,
  # you should either disable this parameter or increase to at least 64M if you
  # want the USB ports to work.
  boot.kernelParams = ["cma=32M"];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };


  ########################
  # Host-specific config #
  ########################

  networking.hostName = "LabPi";
  networking.wireless.enable = false;

  time.timeZone = "America/New_York";

  # SSH configuration
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # sudo configuration
  security.sudo.wheelNeedsPassword = false;


  ###################
  # User management #
  ###################

  # Fully control all user settings declaratively
  # i.e. "passwd" command will be non-effective
  users.mutableUsers = false;

  users.users.root = {
    shell = pkgs.zsh;
    hashedPassword = "$6$ufQLBP4rG53YTioa$ZPSMcw9NZsh8u1rOqnb5X6PdVbIfK6z/eqtOHx3XAVXD9onmPFUm3YpJ6.u81pXGxjBfOeoiiahqNy9Q2UdSY1";
  };

  users.users.lhcb = {
    isNormalUser = true;
    home = "/home/lhcb";
    description = "UMD LHCb group user";
    extraGroups = [ "wheel" "gpio" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$YbrmEXwgx$iIwwI9WcKKOaVP2nWhqzGqTDSQzmDfhiTUPGItT2eWM61Kjd2zgHB.6r.ATDyiHpMYpsmr3DMU1FG1yt1LILM.";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1s0sy5xORVQZcM7Yg1UcxqxGOazY41kci43OV0aqX7owjrxJKhezeOU0uehcvr2uaJykF5wRphaMjiY5tmaVyh35RKZ7tu5B7bx0FOjgATrUFAcBgKqzVMeCSmvmSUNK02HYrP+SOWbdgYECkyF+7PVxZoUefPnpBfGiqunfBWD5YrJMJPToFRqRW7Lcl+/6wIZQOAvPq8lvhfG89r9SvdiEX8umpYJKRgIl9k5wOsimTFJ5wLfq39sjECIzGCcbVLkiPzkOPLWRRgamICbiN4f0HF8kqdDU0mD1WZ5wHM72P68WKpHhMn9l+NEsGYik0fkW+RvyQmnXrpCkMXg3d"
    ];
  };
}
