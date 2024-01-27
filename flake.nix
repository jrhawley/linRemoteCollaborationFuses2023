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
      snakemake
    ]);
    r-deps = (with pkgs.rPackages; [
      data_table
      ggdag
      ggplot2
      here
    ]);
    py-deps = (with pkgs.python311Packages; [
      numpy
      pandas
      statsmodels
    ]);
  in {
    devShells = {
     ${system}.default = pkgs.mkShell {
       packages =  deps ++ r-deps ++ py-deps;
     };
    };
  };
}
