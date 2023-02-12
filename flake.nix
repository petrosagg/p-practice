{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    devShell = nixpkgs.mkShell{
      buildInputs = [


      ]
    };
  };
}
