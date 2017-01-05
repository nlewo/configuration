{ config, lib, pkgs, ... }:

{
  imports = [ 
      	      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix> ];

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      users.users.root.password = "root";

      system.autoUpgrade = {
        enable = true;
	channel = "/var/nixpkgs";
	extraPath = [ pkgs.git ];
	preRebuild =
	''
	mkdir -p /var/nixpkgs/
	git -C /var/nixpkgs init
        git -C /var/nixpkgs remote add origin https://github.com/nlewo/nixpkgs.git || true
	git -C /var/nixpkgs fetch
        git -C /var/nixpkgs reset --hard origin/arn

        mkdir -p /etc/nixos/
	git -C /etc/nixos init
        git -C /etc/nixos remote add origin https://github.com/nlewo/configuration.git || true
	git -C /etc/nixos fetch
        git -C /etc/nixos reset --hard origin/master
	'';
	dates = null;
	period = "1m";
	};

}
