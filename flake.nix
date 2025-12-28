{
  description = "R environment with jupyterlab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

   outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    libs = with pkgs; [
      #gdal
      #expat
    ];
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ pkgs.uv ] ++ libs;

      shellHook = ''
        export VIRTUAL_ENV="$(pwd)/.venv"
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libs}:$LD_LIBRARY_PATH"

        uv add -r requirements.txt
        uv sync
        source .venv/bin/activate
      '';
    };
  };
}