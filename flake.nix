{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko.url = "github:nix-community/disko";
    # disko.inputs.nixpkgs.follows = "nixpkgs";
    # vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = {...} @ inputs:
    with inputs; let
      inherit (self) outputs;
      stateVersion = "24.05";
      libx = import ./lib {inherit inputs outputs stateVersion;};
    in {
      colmena = {
        meta = {
          nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
          specialArgs = {
            inherit inputs outputs stateVersion self;
            # Add a dedicated secretsPath argument
            secretsPath = "/var/lib/agenix-secrets/";
          };
        };
        defaults = {
          lib,
          config,
          name,
          ...
        }: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            ./users/mkn
            ./modules/tg-notify
            # Import agenix module in defaults so it's available everywhere
            inputs.agenix.nixosModules.default
          ];
        };
        titan = import ./hosts/titan;
      };
    };
}
