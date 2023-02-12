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
        p = (pkgs.callPackage ./pkgs/p { });
        coyote = (pkgs.callPackage ./pkgs/coyote { });
        pc = pkgs.writeShellScriptBin "pc" ''exec ${p}/bin/P "$@"'';
        pmc = pkgs.writeShellScriptBin "pmc" ''exec ${coyote}/bin/coyote test "$@"'';
      in pkgs.mkShell {
        buildInputs = [ pc pmc pkgs.dotnet-sdk_3 ];
      };
  };
}
