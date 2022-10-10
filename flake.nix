{
  description = "LORA - the LibreOffice Recovery Assistant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      drv = pkgs.stdenv.mkDerivation {
        pname = "lora";
        version = "0.0.1dev";
        src = ./.;
        buildInputs = with pkgs; [ bash yq libreoffice ];
        installPhase = ''
          mkdir -p $out/bin
          cp lora.sh $out/bin/lora
          '';
        meta = {
          homepage = "https://github.com/pinselimo/lora";
          license = pkgs.lib.licenses.mit;
        };
      };

    in {
      apps.default = {
        type = "app";
        program = "${drv}/bin/lora";
      };
      packages.default = drv;
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ bashInteractive ];
        buildInputs = with pkgs; [ bash yq libreoffice ];
      };
    });
}
