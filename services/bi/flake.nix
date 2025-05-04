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
            export DBT_PROFILES_DIR="$PWD/dbt"
            
            echo "BI environment activated with DuckDB 1.2.2 and Poetry!"
            
            # Create a helper function for activating the virtualenv directly
            poetry_activate() {
              if [ -d "$(poetry env info --path 2>/dev/null)" ]; then
                . "$(poetry env info --path)/bin/activate" || echo "Error activating environment, but shell remains open."
              else
                echo "Poetry environment not found. Run 'poetry env use python' first."
                return 1
              fi
            }

            # Create dev helper function that runs the duckdb CLI directly from the models directory
            dev() {
              # Run the command
              cd $DBT_PROFILES_DIR
              python -m dbt.adapters.duckdb.cli "$@"
            }
            
            # Create an error-tolerant version of common commands
            safe_run() {
              "$@" || echo "Command failed with status $?, but shell remains open."
            }
            
            # Make sure the data directory exists
            mkdir -p data
            
            # Export the functions so they're available in the shell
            export -f poetry_activate
            export -f dbt_run
            export -f dev
            export -f safe_run
            
            # Automatically activate the Poetry environment if it exists
            if [ -d "$(poetry env info --path 2>/dev/null)" ]; then
              echo "Activating Poetry environment automatically..."
              poetry_activate
            else
              echo "No Poetry environment found. To set up your Python environment:"
              echo "  1. Run 'poetry init' (first time only)"
              echo "  2. Run 'poetry add dbt-core dbt-duckdb'"
              echo "  3. Run 'poetry env use python'"
              echo "  4. Next time you enter the shell, the environment will activate automatically"
            fi
            
            echo ""
            echo "To run dbt commands without specifying the profiles directory:"
            echo "  dbt_run init    # Instead of: dbt init --profiles-dir ./models"
            echo "  dbt_run run     # Instead of: dbt run --profiles-dir ./models"
            echo ""
            echo "To run the dbt-duckdb CLI directly from the models directory:"
            echo "  dev             # Runs python -m dbt.adapters.duckdb.cli from the models directory"
            echo ""
            echo "To run commands without the shell exiting on errors, use 'safe_run':"
            echo "  Example: safe_run dbt_run init"
            echo ""
            echo "Note: This shell is configured to stay open even when commands fail."
            echo "Your dbt profiles.yml is located at: ./models/profiles.yml"
          '';
        });
      }
    );
}