{ stdenv
, fetchFromGitHub
, lib
, buildDotnetModule
, dotnetCorePackages
, autoPatchelfHook
, jre
}:

buildDotnetModule rec {
  pname = "p";
  version = "1.1.20";

  src = fetchFromGitHub {
    owner = "p-org";
    repo = "P";
    rev = "p-${version}";
    hash = "sha256-MFewY3LjNJlqjIN5ZDzmcYRKZLM5F3w2ZViG1+ksv40=";
  };

  projectFile = "P.sln";

  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_3_1;
  dotnet-runtime = dotnetCorePackages.runtime_3_1;

  executables = [ "P" ];

  postPatch = ''
    sed -i 's|/usr/bin/java|${jre}/bin/java|g' $(find -name '*.csproj')
  '';

  buildInputs = [ stdenv.cc.cc.lib ];

  nativeBuildInputs = [ autoPatchelfHook ];

  meta = with lib; {
    description = "A high-level state machine based programming language to formally model and specify distributed systems.";
    homepage = "https://p-org.github.io/P/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
