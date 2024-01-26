{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    deps = (with pkgs; [
      R
      python3
    ]);
  in {
    devShells = {
     ${system}.default = pkgs.mkShell {
       packages =  deps;
     };
    };
  };
}
