{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware.nix
      	      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix> ];

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      users.users.root.password = "root";

      system.autoUpgrade = {
        enable = true;
	channel = "https://nixos.org/channels/nixos-unstable";
	extraPath = [ pkgs.git ];
	preRebuild =
	''
        mkdir -p /etc/nixos/
	pushd /etc/nixos/
	git init
        git remote add origin https://github.com/nlewo/configuration.git || true
	git fetch
        git reset --hard origin/master
	popd
	'';
	dates = null;
	period = "1m";
	};

}
