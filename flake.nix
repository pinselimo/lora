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
        #nativeBuildInputs = with pkgs; [ makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin
          cp lora.sh $out/bin/lora.sh
          '';
          #wrapProgram $out/bin/lora.sh \
            #--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.yq pkgs.libreoffice ]}
        #'';
      };

    in {
      apps.default = {
        type = "app";
        program = "${drv}/bin/lora.sh";
      };
      packages.default = drv;
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ bashInteractive ];
        buildInputs = with pkgs; [ bash yq libreoffice ];
      };
    });
}
