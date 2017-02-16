{config, lib, pkgs, ... }:

with lib;

let
  grubConf = pkgs.writeText "grubConf" ''
    {
    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    # Define on which hard drive you want to install Grub.
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;
    }
    '';
in
{
  system.build.novaImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit pkgs lib config;
    partitioned = true;
    diskSize = 1 * 1024;
    format = "qcow2";
    };

  imports = [ <nixpkgs/nixos/modules/virtualisation/nova-image.nix> ./configuration.nix ];

  # Allow root logins
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.cloud = {
          home = "/home/cloud";
          createHome = true;
          group = "cloud";
          extraGroups = [ "wheel" ];
          shell = "/bin/sh";
	  openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDL2uPOWqm3a3FCwzDCW66zMqUMMMTeYiP1GIusLtHDr9jWAa7bDufbm/ODuZ67HHH4hbEeXxjVdz3YRLQoIzLi8DNoWgIVZa9QRp8slN1do1dhmBlFqzH+RKdQ9xLJIWZWGLv1y8EJvvQWBvNrr2wDL2qr8r6Eic+6OMCEP1zF9bVDpPzx7L8g8JUXViO18Ax+yXUkrySKCB9hXrr03ITCzE2uHAYU4OdiIFi1joBOBabktNReTYlAFmPeGSwpnjX/Ke5/fR50dTnQ6YY/smDZqlCPvl/npHBYpL9xsUmDnAkc4hFhOvTIBbf/3ShVsVq32xucpHrDkxNH7K9l+EHL doido@seb.local" ];
        };

     # We create machine dependant files such as grub and hardware
     # configuration.
     systemd.services.nixos-bootstrap = {
       description = "NixOS Bootstrap";
       restartIfChanged = true;
       serviceConfig.RemainAfterExit = true;
       serviceConfig.Type = "oneshot";
       wantedBy = [ "nixos-upgrade.service" ];
       environment = config.nix.envVars //
         { inherit (config.environment.sessionVariables) NIX_PATH;
           HOME = "/root";
         };
       # TODO: path could be cleaned
       path = [ pkgs.gnutar pkgs.xz.bin config.nix.package.out ];
       script = ''
         set -eux
 	cp ${grubConf} /etc/nixos/grub-configuration.nix
 	# We don't want to generate configuration.nix since it will be
 	# fetched from a repo.
 	${config.system.build.nixos-generate-config}/bin/nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
       '';
     };
}
