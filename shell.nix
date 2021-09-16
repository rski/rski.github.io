with import <nixpkgs> {};
let
  name = "rski.github.io";
in
let
  gems = bundlerEnv {
    name = name;
    inherit ruby;
    gemdir = ./.;
  };
in mkShell {
  nativeBuildInputs = [gems ruby];
}
