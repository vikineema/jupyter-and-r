{
  description = "R environment with jupyterlab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

   outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    rWrapper = pkgs.rWrapper;
    # Include desired R packages desired here.
    RPackages = with pkgs.rPackages; [ 
        tidyverse
        IRkernel
      ]; 
    rEnv = rWrapper.override {packages = RPackages; };
    setupRKernel = pkgs.writeShellScript "r-kernel-setup" ./r_kernel.sh;
    setupUV = pkgs.writeShellScript "uv-setup" ./uv_setup.sh;

  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [ 
        uv
        rEnv
        ];

      shellHook = ''
        export VIRTUAL_ENV="$(pwd)/.venv"
        
        # Check where the python kernel is installed in the virtual
        # environment using "jupyter kernelspec list" and set KERNEL_DIR
        # accordingly.
        export KERNEL_DIR="$VIRTUAL_ENV/share/jupyter/kernels"

        # Install the R kernel spec into the virtual environment's
        # Jupyter kernels directory.
        export IRKERNEL_DIR="$KERNEL_DIR/ir"
        mkdir -p "$IRKERNEL_DIR"

        # Copy the files using interpolation
        cp -r ${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec/* $IRKERNEL_DIR/

        # Add write permission
        chmod -R u+w $IRKERNEL_DIR
        echo "Jupyter with R kernel is ready. Run: 'jupyter lab' to launch"

        # Install python packages using uv
        # Include desired python packages in requirements.txt
        uv add -r requirements.txt
        uv sync
        source "$VIRTUAL_ENV"/bin/activate
      '';
    };
  };
}