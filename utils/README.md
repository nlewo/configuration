Scripts here can be used to build images where the configuration is
initially applied.

To create some files that are specific to a machine, we enable a
boostrap systemd service called `nixos-bootstrap`. This service
currently installs the grub configuration and generates the hardware
configuration before running any `nixos-rebuild`.