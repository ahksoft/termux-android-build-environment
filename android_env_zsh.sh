#!/data/data/com.termux/files/usr/bin/bash

# Complete Android Build Environment Setup Script - ZSH VERSION
# Specifically for .zshrc configuration

SCRIPT_VERSION="1.5"
SCRIPT_NAME="Android Build Environment Setup (ZSH)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SHELL_RC="$HOME/.zshrc"
SHELL_NAME="zsh"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Custom progress bar function
show_progress() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    local i=0
    
    printf "${BLUE}[INFO]${NC} %s " "$message"
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    
    printf "\r${GREEN}[SUCCESS]${NC} %s completed!     \n" "$message"
}

# Custom download progress function with percentage (without "present")
download_with_percentage() {
    local url=$1
    local output=$2
    local description=$3
    
    print_status "Downloading $description..."
    
    # Use wget with progress bar and parse output
    wget "$url" -O "$output" 2>&1 | while IFS= read -r line; do
        if [[ $line =~ [0-9]+% ]]; then
            local percent=$(echo "$line" | grep -o "[0-9]*%" | head -1)
            if [ -n "$percent" ]; then
                echo -ne "\r${BLUE}[INFO]${NC} $description: $percent     "
            fi
        fi
    done
    
    # Check if download was successful
    if [ -f "$output" ]; then
        echo -e "\r${GREEN}[SUCCESS]${NC} $description: 100% completed!     "
        return 0
    else
        echo -e "\r${RED}[ERROR]${NC} $description: Failed!     "
        return 1
    fi
}

# Function to check installation status and return missing components
check_missing_components() {
    local missing=()
    
    # Check Java
    if ! command_exists java; then
        missing+=("java")
    fi
    
    # Check Gradle
    if ! command_exists gradle && [ ! -d "$PREFIX/opt/gradle" ]; then
        missing+=("gradle")
    fi
    
    # Check Android tools
    if ! command_exists sdkmanager; then
        missing+=("sdkmanager")
    fi
    
    # Check Android SDK
    if [ ! -d "$PREFIX/opt/Android/sdk" ]; then
        missing+=("android-sdk")
    fi
    
    # Check ARM64 tools
    if [ ! -d "$PREFIX/opt/Android/sdk/platform-tools" ] || [ ! -d "$PREFIX/opt/Android/sdk/build-tools/35.0.2" ]; then
        missing+=("arm64-tools")
    fi
    
    echo "${missing[@]}"
}

# Function to install missing components
install_missing_components() {
    print_status "Checking for missing components..."
    
    local missing=($(check_missing_components))
    
    if [ ${#missing[@]} -eq 0 ]; then
        print_success "All components are already installed!"
        return 0
    fi
    
    print_status "Missing components: ${missing[*]}"
    
    # Work in home directory
    cd $HOME
    
    # Install missing components
    for component in "${missing[@]}"; do
        case $component in
            "java")
                print_status "Installing Java..."
                pkg install -y openjdk-17
                print_success "Java installed"
                ;;
            "gradle")
                print_status "Installing Gradle..."
                if download_with_percentage "https://services.gradle.org/distributions/gradle-7.6.6-bin.zip" "gradle.zip" "Gradle 7.6.6"; then
                    unzip -q gradle.zip
                    mkdir -p "$PREFIX/opt"
                    mv gradle-7.6.6 "$PREFIX/opt/gradle"
                    rm gradle.zip
                    print_success "Gradle installed"
                else
                    print_error "Failed to install Gradle"
                fi
                ;;
            "sdkmanager")
                print_status "Installing Android command-line tools..."
                if download_with_percentage "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip" "cmdline-tools.zip" "Command-line Tools"; then
                    unzip -q cmdline-tools.zip
                    mkdir -p "$PREFIX/opt/Android/sdk/cmdline-tools/latest"
                    mv cmdline-tools/* "$PREFIX/opt/Android/sdk/cmdline-tools/latest/"
                    rm cmdline-tools.zip
                    print_success "Command-line Tools installed"
                else
                    print_error "Failed to install Command-line Tools"
                fi
                ;;
            "android-sdk")
                print_status "Creating Android SDK structure..."
                mkdir -p "$PREFIX/opt/Android/sdk"
                mkdir -p "$PREFIX/opt/Android/sdk/cmdline-tools"
                mkdir -p "$PREFIX/opt/Android/sdk/platforms"
                mkdir -p "$PREFIX/opt/Android/sdk/build-tools"
                print_success "Android SDK structure created"
                ;;
            "arm64-tools")
                print_status "Installing ARM64 SDK tools..."
                install_arm64_sdk_tools
                ;;
        esac
    done
    
    print_success "Missing components installation completed!"
}

# Function to install ARM64 SDK tools from GitHub
install_arm64_sdk_tools() {
    print_status "Installing ARM64 Android SDK Tools from GitHub..."
    
    # Work in home directory
    cd $HOME
    
    # Download ARM64 specific SDK tools
    print_status "Downloading ARM64 Android SDK Tools..."
    if download_with_percentage "https://github.com/lzhiyong/android-sdk-tools/releases/download/35.0.2/android-sdk-tools-static-aarch64.zip" "sdk-tools.zip" "ARM64 SDK Tools"; then
        print_status "Installing ARM64 SDK Tools..."
        unzip -q sdk-tools.zip
        
        # Create necessary directories
        mkdir -p "$PREFIX/opt/Android/sdk/platform-tools"
        mkdir -p "$PREFIX/opt/Android/sdk/build-tools/35.0.2"
        
        # Move platform-tools
        if [ -d "platform-tools" ]; then
            mv platform-tools/* "$PREFIX/opt/Android/sdk/platform-tools/"
            rmdir platform-tools
        fi
        
        # Move build-tools
        if [ -d "build-tools" ]; then
            mv build-tools/* "$PREFIX/opt/Android/sdk/build-tools/35.0.2/"
            rmdir build-tools
        fi
        
        rm sdk-tools.zip
        print_success "ARM64 SDK Tools installed successfully"
    else
        print_error "Failed to download ARM64 SDK Tools"
    fi
}

# Function to source shell configuration
source_shell_config() {
    print_status "Sourcing shell configuration..."
    if [ -f "$SHELL_RC" ]; then
        source "$SHELL_RC" 2>/dev/null
        print_success "Shell configuration sourced successfully"
    else
        print_error "Shell configuration file not found: $SHELL_RC"
    fi
}

# Function to accept licenses and install packages
accept_licenses_and_install_packages() {
    print_status "Accepting Android SDK licenses and installing packages..."
    
    if command_exists sdkmanager; then
        # Accept licenses
        print_status "Accepting Android SDK licenses..."
        echo "y" | sdkmanager --licenses >/dev/null 2>&1 &
        show_progress $! "Accepting licenses"
        print_success "Android SDK licenses accepted"
        
        # Install Android Platform 35
        print_status "Installing Android Platform 35..."
        echo "y" | sdkmanager "platforms;android-35" >/dev/null 2>&1 &
        show_progress $! "Installing Android Platform 35"
        print_success "Android Platform 35 installed"
        
        # Install additional build tools
        print_status "Installing additional build tools..."
        echo "y" | sdkmanager "platform-tools" "build-tools;35.0.2" >/dev/null 2>&1 &
        show_progress $! "Installing build tools"
        print_success "Additional build tools installed"
    else
        print_error "sdkmanager not found. Please install Android command-line tools first."
    fi
}

# Function to uninstall Gradle and Android components (keep Java)
uninstall_android_components() {
    print_warning "This will uninstall Gradle and Android components but keep Java packages."
    read -p "Continue? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_status "Uninstalling Gradle and Android components..."
        
        # Uninstall Gradle
        if [ -d "$PREFIX/opt/gradle" ]; then
            print_status "Removing Gradle..."
            rm -rf "$PREFIX/opt/gradle"
            print_success "Gradle uninstalled"
        else
            print_status "Gradle not found, nothing to uninstall"
        fi
        
        # Uninstall Android SDK
        if [ -d "$PREFIX/opt/Android" ]; then
            print_status "Removing Android SDK..."
            rm -rf "$PREFIX/opt/Android"
            print_success "Android SDK uninstalled"
        else
            print_status "Android SDK not found, nothing to uninstall"
        fi
        
        # Clean environment variables
        print_status "Cleaning environment variables from $SHELL_RC..."
        if [ -f "$SHELL_RC" ]; then
            # Create backup
            cp "$SHELL_RC" "${SHELL_RC}.backup.uninstall.$(date +%s)" 2>/dev/null
            
            # Remove Android environment entries
            if grep -q "Android Build Environment" "$SHELL_RC"; then
                grep -v "Android Build Environment" "$SHELL_RC" > "${SHELL_RC}.tmp" 2>/dev/null
                if [ -f "${SHELL_RC}.tmp" ]; then
                    mv "${SHELL_RC}.tmp" "$SHELL_RC"
                    print_success "Android environment variables removed from $SHELL_RC"
                fi
            else
                print_status "No Android environment variables found in $SHELL_RC"
            fi
        else
            print_warning "$SHELL_RC not found"
        fi
        
        print_success "Uninstallation of Android components completed!"
        print_warning "Please restart your terminal or run: source $SHELL_RC"
    else
        print_status "Uninstallation cancelled."
    fi
}

# Main installation function
perform_complete_installation() {
    print_status "Starting complete Android build environment installation for ZSH..."
    
    # Work in home directory to avoid permission issues
    cd $HOME
    
    # 1. Install required Termux packages
    print_status "1. Installing required Termux packages..."
    pkg update -y
    if pkg install -y \
        openjdk-17 \
        wget \
        unzip \
        nano \
        git \
        which \
        libxml2 \
        libxslt \
        python; then
        print_success "Termux packages installed successfully"
    else
        print_error "Failed to install Termux packages"
    fi
    
    # 2. Create Android SDK directory structure
    print_status "2. Creating Android SDK directory structure..."
    mkdir -p "$PREFIX/opt/Android/sdk"
    mkdir -p "$PREFIX/opt/Android/sdk/cmdline-tools"
    mkdir -p "$PREFIX/opt/Android/sdk/platforms"
    mkdir -p "$PREFIX/opt/Android/sdk/build-tools"
    
    # 3. Setup environment variables
    print_status "3. Setting up environment variables in $SHELL_RC..."
    ENV_VARS='
# Android Build Environment (ZSH)
export ANDROID_HOME="$PREFIX/opt/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/build-tools/35.0.2"
export JAVA_HOME="/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk"
export GRADLE_HOME="$PREFIX/opt/gradle"
export PATH="$PATH:$GRADLE_HOME/bin"
'
    
    # Backup original file
    if [ -f "$SHELL_RC" ]; then
        cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%s)" 2>/dev/null
    fi
    
    # Remove old Android environment entries
    if [ -f "$SHELL_RC" ] && grep -q "Android Build Environment (ZSH)" "$SHELL_RC"; then
        grep -v "Android Build Environment (ZSH)" "$SHELL_RC" > "${SHELL_RC}.tmp"
        mv "${SHELL_RC}.tmp" "$SHELL_RC"
        print_status "Removed old Android environment entries"
    fi
    
    # Add new environment variables
    echo "$ENV_VARS" >> "$SHELL_RC"
    print_success "Environment variables added to $SHELL_RC"
    
    # Instructions for manual sourcing (avoiding zsh conflicts)
    print_warning "Please manually run: source $SHELL_RC"
    print_warning "Or restart your terminal to apply changes"
    
    # 4. Setup storage access
    print_status "4. Setting up storage access..."
    termux-setup-storage
    
    # 5. Download and install Gradle
    print_status "5. Downloading Gradle 7.6.6..."
    if download_with_percentage "https://services.gradle.org/distributions/gradle-7.6.6-bin.zip" "gradle.zip" "Gradle 7.6.6"; then
        print_status "Installing Gradle..."
        unzip -q gradle.zip
        mkdir -p "$PREFIX/opt"
        mv gradle-7.6.6 "$PREFIX/opt/gradle"
        rm gradle.zip
        print_success "Gradle installed successfully"
    else
        print_error "Failed to download Gradle"
    fi
    
    # 6. Install android tools
    print_status "6. Installing android-tools..."
    if pkg install -y android-tools; then
        print_success "Android tools installed successfully"
    else
        print_error "Failed to install android-tools"
    fi
    
    # 7. Download and install Command-line Tools
    print_status "7. Downloading Android Command-line Tools..."
    if download_with_percentage "https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip" "cmdline-tools.zip" "Command-line Tools"; then
        print_status "Installing Command-line Tools..."
        unzip -q cmdline-tools.zip
        mv cmdline-tools "$PREFIX/opt/Android/sdk/cmdline-tools/latest"
        rm cmdline-tools.zip
        print_success "Command-line Tools installed successfully"
    else
        print_error "Failed to download Command-line Tools"
    fi
    
    # 8. Install ARM64 SDK tools from GitHub
    install_arm64_sdk_tools
    
    # 9. Accept licenses and install additional packages
    accept_licenses_and_install_packages
    
    print_success "Complete Android build environment installation finished!"
    print_warning "Please restart your terminal or run: source $SHELL_RC"
}

# Function to show menu
show_menu() {
    echo ""
    echo "=== $SCRIPT_NAME v$SCRIPT_VERSION ==="
    echo "Specifically for .zshrc configuration"
    echo ""
    echo "Options:"
    echo "  1) Complete installation (all components)"
    echo "  2) Install missing components"
    echo "  3) Install ARM64 SDK tools from GitHub"
    echo "  4) Source shell configuration"
    echo "  5) Accept licenses and install packages"
    echo "  6) Uninstall Android components (keep Java)"
    echo "  7) Check installation status"
    echo "  8) Exit"
    echo ""
}

# Function to check installation status
check_installation_status() {
    print_status "Checking current installation status..."
    echo "----------------------------------------"
    
    # Check Java
    if command_exists java; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1)
        print_success "Java is installed: $JAVA_VERSION"
    else
        print_error "Java is not installed"
    fi
    
    # Check Gradle
    if command_exists gradle; then
        GRADLE_VERSION=$(gradle --version 2>/dev/null | grep "Gradle" | head -n 1)
        print_success "Gradle is installed: $GRADLE_VERSION"
    elif [ -d "$PREFIX/opt/gradle" ]; then
        print_success "Gradle is installed at $PREFIX/opt/gradle (but not in PATH)"
    else
        print_error "Gradle is not installed"
    fi
    
    # Check Android tools
    if command_exists sdkmanager; then
        print_success "sdkmanager is available"
    else
        print_error "sdkmanager is not available"
    fi
    
    if command_exists adb; then
        print_success "adb is available"
    else
        print_error "adb is not available"
    fi
    
    # Check Android SDK
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        print_success "Android SDK is configured: $ANDROID_HOME"
    elif [ -d "$PREFIX/opt/Android/sdk" ]; then
        print_success "Android SDK found at $PREFIX/opt/Android/sdk (but ANDROID_HOME not set)"
    else
        print_error "Android SDK is not installed"
    fi
    
    echo "----------------------------------------"
}

# Main function
main() {
    print_status "Configured for: $SHELL_NAME ($SHELL_RC)"
    
    while true; do
        show_menu
        read -p "Enter your choice (1-8): " choice
        
        case $choice in
            1)
                perform_complete_installation
                ;;
            2)
                install_missing_components
                ;;
            3)
                install_arm64_sdk_tools
                ;;
            4)
                source_shell_config
                ;;
            5)
                accept_licenses_and_install_packages
                ;;
            6)
                uninstall_android_components
                ;;
            7)
                check_installation_status
                ;;
            8)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-8."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
