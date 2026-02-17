{
  description = "Flake for fastfetch that uses Magick engine";

  inputs = {
    fastfetch.url = "github:reaI-crtl/fastfetch";
    fastfetch.flake = false;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, fastfetch, nixpkgs}:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      # Build
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

      # Options
      homeModules.default = { config, lib, pkgs, ... }:
      let
        cfg = config.programs.fastfetch-magick;
      in {
        options.programs.fastfetch-magick = {
          enable = lib.mkEnableOption "Fastfetch Magick";
  
          settings = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Fastfetch JSON configuration.";
          };
        };
  
        config = lib.mkIf cfg.enable {
          home.packages = [ self.packages.${system}.fastfetch-magick ];
  
          # xdg.configFile."fastfetch/config.json".text =
          #   builtins.toJSON cfg.settings;

          home.file.".config/fastfetch/config.jsonc".text =
            builtins.toJSON cfg.settings;
        };
      };

    };
}