{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    devShell.x86_64-linux =
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      in pkgs.mkShell {
        buildInputs = [
          (pkgs.callPackage ./pkgs/p { })
          (pkgs.callPackage ./pkgs/coyote { })
        ];
      };
  };
}
