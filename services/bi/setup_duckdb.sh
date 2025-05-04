#!/bin/bash

# Simple script to setup a locally installed DuckDB (outside of Nix)
# This installs DuckDB in a local directory so it's not affected by Nix's immutable filesystem

# Configuration
DUCKDB_VERSION="1.2.2"
INSTALL_DIR="$PWD/.local/bin"
DOWNLOAD_DIR="$PWD/.local/tmp"
PLATFORM="linux_amd64"  # Adjust if needed (e.g., linux_arm64, osx_amd64)

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to PATH"
    export PATH="$INSTALL_DIR:$PATH"
    
    # Also update .bashrc or .zshrc if it exists to make the change permanent
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "export PATH=\"$INSTALL_DIR:\$PATH\"" "$HOME/.bashrc"; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
            echo "Updated .bashrc with new PATH"
        fi
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "export PATH=\"$INSTALL_DIR:\$PATH\"" "$HOME/.zshrc"; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
            echo "Updated .zshrc with new PATH"
        fi
    fi
fi

# Check if DuckDB is already installed
if [ -f "$INSTALL_DIR/duckdb" ]; then
    echo "DuckDB already installed at $INSTALL_DIR/duckdb"
    echo "Version: $($INSTALL_DIR/duckdb --version | head -n 1)"
    echo "If you want to reinstall, delete $INSTALL_DIR/duckdb first"
    exit 0
fi

# Download and install DuckDB
echo "Downloading DuckDB $DUCKDB_VERSION for $PLATFORM..."
cd "$DOWNLOAD_DIR"

# Download the CLI binary
curl -L -o duckdb "https://github.com/duckdb/duckdb/releases/download/v$DUCKDB_VERSION/duckdb_cli-$PLATFORM.zip"

# Unzip the binary
unzip duckdb

# Make it executable
chmod +x duckdb

# Move to install directory
mv duckdb "$INSTALL_DIR/"

# Cleanup
cd - > /dev/null
rm -rf "$DOWNLOAD_DIR"

echo "DuckDB $DUCKDB_VERSION installed at $INSTALL_DIR/duckdb"
echo "You can now run DuckDB using: $INSTALL_DIR/duckdb"
echo "Since $INSTALL_DIR is in your PATH, you can simply use: duckdb"

# Create a configuration file for DuckDB
mkdir -p "$PWD/.local/config"
cat > "$PWD/.local/config/duckdb.config" << EOF
# DuckDB configuration
# This file should be loaded with: duckdb -init "$PWD/.local/config/duckdb.config"

# Set extension directory to a writable location
extension_directory=$PWD/.local/extensions

# Options for UI extensions
autoinstall_known_extensions=1
autoload_known_extensions=1
EOF

mkdir -p "$PWD/.local/extensions"

# Create a wrapper script for DuckDB with UI
cat > "$INSTALL_DIR/duckdb-ui" << EOF
#!/bin/bash

# Wrapper script for DuckDB with UI extensions

# Configuration
CONFIG_FILE="$PWD/.local/config/duckdb.config"
DUCKDB_BIN="$INSTALL_DIR/duckdb"

# Run DuckDB with UI
\$DUCKDB_BIN "\$@" -init "\$CONFIG_FILE" --ui
EOF

chmod +x "$INSTALL_DIR/duckdb-ui"

echo "Created a wrapper script at $INSTALL_DIR/duckdb-ui"
echo "To run DuckDB with UI, use: duckdb-ui <database_file>"
echo ""
echo "Example: duckdb-ui $PWD/bi.duckdb"
