{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    panfactum.url = "github:panfactum/stack/main";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    duckdb-nix.url = "github:rupurt/duckdb-nix";
  };

  outputs = { self, flake-utils, panfactum, nixpkgs, duckdb-nix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        baseShell = panfactum.lib.${system}.mkDevShell { };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ duckdb-nix.overlay ];
        };
      in
      {
        devShells.default = baseShell.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [
            pkgs.duckdb-pkgs.v1_2_2
            pkgs.poetry
            pkgs.python312
            # Add system libraries needed for DuckDB
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
            pkgs.libxml2
          ];

          shellHook = ''
            # Set up error handling that doesn't exit the shell on errors
            set +e  # Disable exit on error
            
            # Execute the original shellHook inside a subshell to isolate potential errors
            (
              set -e  # Enable exit on error just for the original shellHook
              ${oldAttrs.shellHook}
            ) || echo "Warning: Some initialization commands had errors, but the shell will remain open."
            
            # Make sure the libraries are available to Python
            export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:${pkgs.libxml2}/lib:$LD_LIBRARY_PATH
            
            # Set DBT_PROFILES_DIR environment variable
            export DBT_PROFILES_DIR="$PWD/models"
            
            echo "BI environment activated with DuckDB 1.2.2 and Poetry!"
            echo "To set up your Python environment:"
            echo "  1. Run 'poetry init' (first time only)"
            echo "  2. Run 'poetry add dbt-core dbt-duckdb'"
            echo "  3. Instead of 'poetry shell', run:"
            echo "     poetry env use python"
            echo "     poetry env activate"
            
            # Create a helper function for activating the virtualenv directly
            poetry_activate() {
              if [ -d "$(poetry env info --path 2>/dev/null)" ]; then
                . "$(poetry env info --path)/bin/activate" || echo "Error activating environment, but shell remains open."
              else
                echo "Poetry environment not found. Run 'poetry env use python' first."
                return 1
              fi
            }

            # Create an error-tolerant version of common commands
            safe_run() {
              "$@" || echo "Command failed with status $?, but shell remains open."
            }
            
            # Make sure the data directory exists
            mkdir -p data
            
            # Export the functions so they're available in the shell
            export -f poetry_activate

            echo "  4. Or use the shortcut command: poetry_activate"
            echo "To run commands without the shell exiting on errors, use 'safe_run':"
          '';
        });
      }
    );
}