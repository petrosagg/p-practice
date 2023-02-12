{ stdenv
, fetchFromGitHub
, lib
, buildDotnetModule
, dotnetCorePackages
, dos2unix
}:
buildDotnetModule rec {
  pname = "coyote";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "coyote";
    rev = "915b5108ae45fc5636886222cff43887c3ec34ef";
    hash = "sha256-ysv0bGBDnSXqY0mtq9zQnRHgv3MfkK7lr15nVAKDucE=";
  };

  prePatch = ''
    dos2unix Coyote.sln
  '';

  patches = [
    ./0001-build-quirks-to-get-nix-build-working.patch
  ];

  projectFile = "Coyote.sln";

  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_3_1;
  dotnet-runtime = dotnetCorePackages.runtime_3_1;

  dotnetInstallFlags = [ "--framework=netcoreapp3.1" ];
  dotnetFlags = [
    "-property:RuntimeFrameworkVersion=${dotnetCorePackages.runtime_3_1.version}"
  ];

  nativeBuildInputs = [ dos2unix ];

  meta = with lib; {
    description = "A library and tool designed to help ensure that your code is free of concurrency bugs.";
    homepage = "https://microsoft.github.io/coyote/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
