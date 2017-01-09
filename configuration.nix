{ config, lib, pkgs, ... }:

let
  gitPull =
    ''
    mkdir -p /var/nixpkgs/
    git -C /var/nixpkgs init
    git -C /var/nixpkgs remote add origin https://github.com/nlewo/nixpkgs.git || true
    git -C /var/nixpkgs pull origin arn

    mkdir -p /etc/nixos/
    git -C /etc/nixos init
    git -C /etc/nixos remote add origin https://github.com/nlewo/configuration.git || true
    git -C /etc/nixos pull origin arn
    ''; 
in
{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix> 
              ./hardware-configuration.nix
	      ./grub-configuration.nix
	    ];

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      users.users.root.password = "root";

      users.extraUsers.lewo = {
         isNormalUser = true;
         extraGroups = [ "wheel" ];
      };
      users.extraUsers.eon = {
         isNormalUser = true;
         extraGroups = [ "wheel" ];
      };

      system.autoUpgrade = {
        enable = true;
	channel = "/var/nixpkgs";
	extraPath = [ pkgs.git ];
	preRebuild = gitPull;
	dates = "*:0/2";
	};
}
