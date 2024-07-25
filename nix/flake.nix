{
  description = "Test flake";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, unstable, ...}:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
    in  {
    nixosConfigurations = {
      mypc = lib.nixosSystem {
        inherit system;
	specialArgs = {
	  unstable = import unstable {
            inherit system;
	    config.allowUnfree = true;
	  };
	  pkgs = import nixpkgs {
            inherit system;
	    config.allowUnfree = true;
	  };
	};
        modules = [ ./configuration.nix ];
      };
    };
  };
}
