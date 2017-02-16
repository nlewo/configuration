{
  computeNode =
    { config, pkgs, ... }:
    let
      grubConf = pkgs.writeText "grubConf" ''
        {
        # Use the GRUB 2 boot loader.
        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        # Define on which hard drive you want to install Grub.
        boot.loader.grub.device = "/dev/sda";
        }
        '';
    in
    { 
      imports = [ ./configuration.nix ];
      deployment.targetEnv = "libvirtd";
      deployment.libvirtd.memorySize = 4096;
      deployment.libvirtd.headless = true;
      deployment.libvirtd.baseImageSize = 20;

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      networking.firewall.allowedTCPPorts = [ 19531 ];
      services.journald.enableHttpGateway = true;

      users.extraUsers.lewo = {
         isNormalUser = true;
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
