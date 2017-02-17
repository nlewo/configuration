{ config, pkgs, ... }:

let
  gitPull =
    ''
    mkdir -p /var/nixpkgs/
    git -C /var/nixpkgs init
    git -C /var/nixpkgs remote add origin https://github.com/nlewo/nixpkgs.git || true
    git -C /var/nixpkgs pull origin arn

    mkdir -p /var/nixos/
    git -C /var/nixos init
    git -C /var/nixos remote add origin https://github.com/nlewo/configuration.git || true
    git -C /var/nixos pull origin arn
    ln -s /var/nixos/configuration/configuration.nix /etc/nixos/configuration.nix
    '';
in
{
  imports = [ ./hardware-configuration.nix
	      ./grub-configuration.nix
	    ];

  networking.firewall.allowedTCPPorts = [ 19531 ];
  services.journald.enableHttpGateway = true;

  system.autoUpgrade = {
    enable = true;
    flags = [ "-I" "nixpkgs=/var/nixpkgs" ];
    extraPath = [ pkgs.git ];
    preRebuild = gitPull;
    dates = "*:0/2";
  };
}
