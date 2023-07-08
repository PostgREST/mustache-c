with import (builtins.fetchTarball {
  name = "2022-10-14";
  url = "https://github.com/NixOS/nixpkgs/archive/cc090d2b942f76fad83faf6e9c5ed44b73ba7114.tar.gz";
  sha256 = "0a1wwpbn2f38pcays6acq1gz19vw4jadl8yd3i3cd961f1x2vdq2";
}) {};
mkShell {
  buildInputs = [ cmake flex bison ];
  shellHook = ''
    export HISTFILE=.history
  '';
}
