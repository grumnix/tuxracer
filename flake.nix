{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    tuxracer_src.url = "http://download.sourceforge.net/tuxracer/tuxracer-0.61.tar.gz";
    tuxracer_src.flake = false;

    tuxracer-data_src.url = "http://download.sourceforge.net/tuxracer/tuxracer-data-0.61.tar.gz";
    tuxracer-data_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, tuxracer_src, tuxracer-data_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = tuxracer;

          tuxracer = pkgs.stdenv.mkDerivation rec {
            pname = "tuxracer";
            version = "0.61";

            src = tuxracer_src;

            patches = [
              ./tuxracer-tokenpasting.patch
            ];

            postPatch = ''
              substituteInPlace src/game_config.c \
                --replace '/usr/local/share/tuxracer' \
                          '${tuxracer-data_src}' \
                --replace 'fullscreen, True,' \
                          'fullscreen, False,'
            '';

            buildInputs = with pkgs; [
              tcl
              libGL
              libGLU
              SDL
              SDL_mixer
            ];
          };
        };
      }
    );
}
