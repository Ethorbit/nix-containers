{
    description = "Collection of reproducible container images built with Nix and nix2container by Ethorbit.";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        ethorbit-packages = {
            url = "github:ethorbit/nix-packages";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        utils.url = "github:numtide/flake-utils";
    };

    outputs = {
        self,
        nixpkgs,
        nixpkgs-unstable,
        ethorbit-packages,
        utils
    }: {
        overlays = {
            default = final: prev: {
                ethorbit = import ./pkgs/packages.nix {
                    pkgs = final;
                    pkgs-unstable = import nixpkgs-unstable {
                        system = final.system;
                        config.allowUnfree = final.config.allowUnfree;
                    };
                    pkgs-ethorbit = ethorbit-packages.overlays.default;
                    lib = final.lib;
                };
            };
        };

        packages = utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                    overlays = [
                        self.overlays.default
                    ];
                };
            in {
                default = pkgs.ethorbit;
            }
        );
    };
}
