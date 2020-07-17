with (import <nixpkgs> {});
let
  name = "rski.github.io";
in
let
  gems = bundlerEnv {
    name = name;
    inherit ruby;
    gemdir = ./.;
  };
in stdenv.mkDerivation {
  name = name;
  buildInputs = [gems ruby];
}
