{
  description = "Flake for fastfetch that uses Magick engine";

  inputs = {
    fastfetch.url = "github:reaI-crtl/fastfetch";
    fastfetch.flake = false;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, fastfetch, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.fastfetch-magick = pkgs.stdenv.mkDerivation {
        pname = "fastfetch-magick";
        version = "0.6.28";

        nativeBuildInputs = [
          pkgs.cmake
        ];

        src = fastfetch; 

        buildPhase = ''
          cmake -B build -S $src
          cmake --build build
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp build/fastfetch $out/bin/
        '';
      };

      defaultPackage.${system} = self.packages.${system}.fastfetch-magick;
    };
}