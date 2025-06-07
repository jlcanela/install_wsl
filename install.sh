#!/bin/sh

# Set NVM_DIR
export NVM_DIR="$HOME/.nvm"

# Try to source nvm if it exists
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

# Now check if nvm is available
if command -v nvm > /dev/null 2>&1; then
    echo "nvm is already installed."
else
    echo "nvm not found. Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    # Source nvm again after install
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
    fi
    echo "nvm installation completed."
fi

# Check if node is installed
if command -v node > /dev/null 2>&1; then
    # Get installed Node.js version
    NODE_VERSION=$(node -v)
    # Get latest LTS version available via nvm
    LATEST_LTS=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
    # Remove 'v' from version strings for comparison
    NODE_VERSION_NUM=${NODE_VERSION#v}
    LATEST_LTS_NUM=${LATEST_LTS#v}
    # Compare installed version with latest LTS
    if [ "$NODE_VERSION_NUM" = "$LATEST_LTS_NUM" ]; then
        echo "Node.js is already installed as the latest LTS ($NODE_VERSION)."
    else
        echo "Node.js is installed ($NODE_VERSION), but not the latest LTS ($LATEST_LTS). Installing latest LTS..."
        nvm install --lts
        nvm use --lts
    fi
else
    echo "Node.js is not installed. Installing latest LTS version with nvm..."
    nvm install --lts
    nvm use --lts
fi

# Check if pnpm is installed
if command -v pnpm > /dev/null 2>&1; then
    echo "pnpm is already installed."
else
    echo "pnpm not found. Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    # Add pnpm to PATH for current session (optional, usually handled by the installer)
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    echo "pnpm installation completed."
fi

# Check if rustc (Rust compiler) is installed
if command -v rustc > /dev/null 2>&1; then
    echo "Rust is already installed: $(rustc --version)"
else
    echo "Rust not found. Installing Rust using rustup..."
    # Download and run the official rustup installer
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add Rust to the current shell session
    source "$HOME/.cargo/env"
    echo "Rust installation completed: $(rustc --version)"
fi

# Check if Java is installed
if command -v java > /dev/null 2>&1; then
    echo "Java is already installed: $(java -version 2>&1 | head -n 1)"
else
    echo "Java not found. Installing default OpenJDK (Java 21 LTS)..."
    sudo apt update
    sudo apt install -y default-jdk
    echo "Java installation completed: $(java -version 2>&1 | head -n 1)"
fi

# Check if Scala is installed
if command -v scala > /dev/null 2>&1; then
    echo "Scala is already installed: $(scala -version 2>&1 | head -n 1)"
else
    echo "Scala not found. Installing Scala using Coursier..."

    # Download Coursier installer (cs)
    curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > cs
    # Make it executable
    chmod +x cs

    # Run Coursier setup to install Scala and related tools
    ./cs setup --yes

    # Add Coursier's bin directory to PATH for the current session
    export PATH="$HOME/.local/share/coursier/bin:$PATH"

    # Remove the cs installer
    rm cs

    echo 'export PATH="$PATH:$HOME/.local/share/coursier/bin"' >> ~/.bashrc
    echo 'export PATH="$PATH:$HOME/.local/share/coursier/bin"' >> ~/.profile

    # Reload the profile to ensure scala is in PATH
    if [ -f "$HOME/.profile" ]; then
      . "$HOME/.profile"
    fi

    # Verify Scala installation
    if command -v scala > /dev/null 2>&1; then
        echo "Scala installation completed: $(scala -version 2>&1 | head -n 1)"
    else
        echo "Scala installation failed. Please check your setup."
        exit 1
    fi
fi

if command -v dotnet > /dev/null 2>&1 && dotnet --list-sdks | grep -q "^9\."; then
    echo ".NET SDK 9 is already installed: $(dotnet --version)"
else
    echo ".NET SDK 9 not found. Installing from dotnet/backports PPA..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:dotnet/backports
    sudo apt update
    sudo apt install -y dotnet9
    if command -v dotnet > /dev/null 2>&1 && dotnet --list-sdks | grep -q "^9\."; then
        echo ".NET SDK 9 installation completed: $(dotnet --version)"
    else
        echo "Failed to install .NET SDK 9. Please check for errors above."
        exit 1
    fi
fi

if ! command -v git > /dev/null 2>&1; then
    echo "Git not found. Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
else
    echo "Git is already installed: $(git --version)"
fi

# Check if user.email is set
user_email=$(git config --global user.email)
if [ -z "$user_email" ]; then
    read -p "Please enter your git user.email: " user_email
    git config --global user.email "$user_email"
fi

# Check if user.name is set
user_name=$(git config --global user.name)
if [ -z "$user_name" ]; then
    read -p "Please enter your git user.name: " user_name
    git config --global user.name "$user_name"
fi

echo "Git global config:"
git config --global --list
