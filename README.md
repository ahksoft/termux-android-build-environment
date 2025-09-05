```markdown
# 🤖 Termux Android Build Environment

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Termux-green.svg)](https://termux.dev)
[![Architecture](https://img.shields.io/badge/arch-ARM64-orange.svg)](#)
[![GitHub Stars](https://img.shields.io/github/stars/ahksoft/termux-android-build-environment)](https://github.com/ahksoft/termux-android-build-environment/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/ahksoft/termux-android-build-environment)](https://github.com/ahksoft/termux-android-build-environment/issues)

A comprehensive, professional Android build environment setup for Termux on ARM64 devices. This script automates the entire process of installing Java, Gradle, Android SDK, and all necessary tools to build Android applications directly on your Android device.

## 🌟 Features

- **Complete Android Development Environment** - Sets up everything needed for Android app development
- **ARM64 Optimized** - Specifically designed for ARM64 architecture with compatible SDK tools
- **Dual Shell Support** - Works with both Bash (.bashrc) and Zsh (.zshrc) configurations
- **Smart Component Detection** - Checks for missing components and installs only what's needed
- **Progress Tracking** - Real-time download progress with percentage indicators
- **Modular Operations** - Install, check, uninstall individual components
- **Safe Uninstallation** - Removes Android/Gradle components while preserving Java
- **Custom Progress Indicators** - Visual feedback during long operations

## 📋 Prerequisites

- **Termux App** - Install from [F-Droid](https://f-droid.org/packages/com.termux/) or Google Play
- **Android 7.0+** - Minimum Android version requirement
- **ARM64 Device** - Script optimized for 64-bit ARM processors
- **Internet Connection** - Required for downloading components (~300MB total)
- **Storage Space** - At least 1GB free space recommended

## 🚀 Quick Installation

### For Bash Users (.bashrc)
```bash
curl -O https://raw.githubusercontent.com/ahksoft/termux-android-build-environment/main/android_env_bash.sh
chmod +x android_env_bash.sh
./android_env_bash.sh
```

### For Zsh Users (.zshrc)
```bash
curl -O https://raw.githubusercontent.com/ahksoft/termux-android-build-environment/main/android_env_zsh.sh
chmod +x android_env_zsh.sh
./android_env_zsh.sh
```

## 🛠️ What Gets Installed

### Core Components
- **OpenJDK 17** - Java development kit for Android development
- **Gradle 7.6.6** - Build automation tool for Android projects
- **Android SDK** - Core Android development kit
- **Command-line Tools** - Official Android SDK command-line interface
- **Platform-tools** - ADB and fastboot utilities
- **Build-tools 35.0.2** - Android build tools for API level 35
- **Android Platform 35** - Android API level 35 platform files

### Termux Packages
```bash
openjdk-17 wget unzip nano git which libxml2 libxslt python android-tools
```

## 🎮 Script Operations

| Option | Description |
|--------|-------------|
| **1** | Complete installation (all components) |
| **2** | Install missing components only |
| **3** | Install ARM64 SDK tools from GitHub |
| **4** | Source shell configuration |
| **5** | Accept licenses and install packages |
| **6** | Uninstall Android components (keep Java) |
| **7** | Check installation status |
| **8** | Exit |

## 📁 Directory Structure

After installation, the following structure is created:
```
$PREFIX/opt/
├── Android/
│   └── sdk/
│       ├── cmdline-tools/
│       │   └── latest/
│       ├── platform-tools/
│       ├── build-tools/
│       │   └── 35.0.2/
│       └── platforms/
│           └── android-35/
└── gradle/
    └── gradle-7.6.6/
```

## 🔧 Environment Variables

The script automatically configures these environment variables:
```bash
export ANDROID_HOME="$PREFIX/opt/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/build-tools/35.0.2"
export JAVA_HOME="/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk"
export GRADLE_HOME="$PREFIX/opt/gradle"
export PATH="$PATH:$GRADLE_HOME/bin"
```

## 🎯 Usage Examples

### Check Installation Status
```bash
./android_env_bash.sh
# Select option 7
```

### Install Only Missing Components
```bash
./android_env_bash.sh
# Select option 2
```

### Uninstall Android Components (Keep Java)
```bash
./android_env_bash.sh
# Select option 6
```

## 📊 Progress Indicators

The script provides visual feedback during operations:
- **Download Progress**: `Downloading Gradle 7.6.6: 45%`
- **Installation Progress**: `[INFO] Installing Command-line Tools... [█]`
- **Operation Completion**: `[SUCCESS] Gradle installed successfully`

## 🔒 Safety Features

- **Backup Creation** - Automatically backs up shell configuration files
- **Selective Uninstall** - Only removes Android/Gradle components, preserves Java
- **Error Handling** - Graceful error handling with descriptive messages
- **Permission Checks** - Validates permissions before operations
- **Network Resilience** - Handles download failures gracefully

## 🐛 Troubleshooting

### Common Issues

1. **sdkmanager not found**
   ```bash
   # Manually install Android tools
   pkg install android-tools
   ```

2. **Permission denied errors**
   ```bash
   # Ensure script is executable
   chmod +x android_env_bash.sh
   ```

3. **Download failures**
   ```bash
   # Check internet connection and retry
   ping google.com
   ```

### Manual Environment Setup
If automatic sourcing fails:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## 📈 Performance Tips

- **Storage**: Ensure sufficient storage space (1GB+ recommended)
- **Network**: Use stable Wi-Fi for downloads (~300MB total)
- **Battery**: Keep device charged during installation
- **Time**: Initial setup takes 10-15 minutes depending on connection

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Termux Team** - For the excellent Android terminal emulator
- **Google Android Team** - For Android SDK tools
- **Gradle Team** - For the build automation tool
- **OpenJDK Team** - For the Java development kit
- **lzhiyong** - For ARM64 compatible Android SDK tools

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/ahksoft/termux-android-build-environment/issues)
- **Documentation**: [Wiki](https://github.com/ahksoft/termux-android-build-environment/wiki)
- **Releases**: [GitHub Releases](https://github.com/ahksoft/termux-android-build-environment/releases)

## 📱 Compatible Devices

Tested on:
- Samsung Galaxy series (ARM64)
- Google Pixel series (ARM64)
- OnePlus devices (ARM64)
- Xiaomi devices (ARM64)

## ⚠️ Disclaimer

This script modifies your Termux environment and installs significant software components. While it includes safety features, always ensure you have backups of important data before running installation scripts.

---

<p align="center">
  Made with ❤️ for the Android development community
</p>
```
