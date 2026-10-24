{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: {
    nixosConfigurations.dango = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
     
      modules = [
        ./configuration.nix
      ];
      };
    
  };
}
 
