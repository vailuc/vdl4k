# vdl4k

A robust YouTube/4K video downloader with modular architecture and global installation system. The goal of this script is to archive videos for personal use, providing an easy way to download and organize high-quality videos while maintaining a download history and supporting batch processing.

## Features
- 4K video support with fallback options
- Automatic resolution comparison and upgrade
- Category-based organization
- Comprehensive logging
- Clipboard URL detection
- Configurable settings
- Modular architecture with separate utility modules
- Robust error handling and validation
- **Global installation system with smart module detection**
- **One-command setup with dependency checking**

## Architecture
vdl4k is built with a modular architecture consisting of:

- **bin/vdl4k**: Main executable script
- **lib/validators.sh**: URL and input validation
- **lib/video_utils.sh**: Video processing functions
- **lib/archive.sh**: Download history management
- **lib/download.sh**: Video download and processing
- **lib/config.sh**: Configuration management
- **install.sh**: Global installation system with smart path detection

## Installation

### Prerequisites
Ensure the following tools are installed on your system:
- **yt-dlp**: Video downloader (install via pip: `pip install yt-dlp` or package manager)
- **ffmpeg**: For video processing (install via `sudo apt install ffmpeg` on Ubuntu/Debian)
- **ffprobe**: Included with ffmpeg
- **xsel** (optional): For clipboard support on Linux (install via `sudo apt install xsel`)

### Quick Install (Recommended)
1. Clone the repository: `git clone <repository-url>`
2. Navigate to the project directory: `cd vdl4k`
3. Run the installation script: `./install.sh`
4. **Done!** vdl4k is now available globally as `vdl4k` and `vdl4k-portable`

The installation script will:
- ✅ Create `~/bin` directory if it doesn't exist
- ✅ Add `~/bin` to your PATH (in `.bashrc` and `.zshrc`)
- ✅ Install both versions globally
- ✅ Check dependencies
- ✅ Make scripts executable

**After installation, restart your terminal or run:**
```bash
source ~/.bashrc
```

**Now you can use vdl4k from anywhere:**
```bash
vdl4k --help
vdl4k <YouTube_URL>
vdl4k-portable <YouTube_URL>
```

### Manual Installation
If you prefer to install manually:

1. Clone the repository: `git clone <repository-url>`
2. Navigate to the project directory: `cd vdl4k`
3. Create local bin directory: `mkdir -p ~/bin`
4. Copy scripts: `cp bin/vdl4k ~/bin/` and `cp vdl4k-portable ~/bin/`
5. Make executable: `chmod +x ~/bin/vdl4k ~/bin/vdl4k-portable`
6. Add to PATH: `echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc`
7. Restart terminal or: `source ~/.bashrc`

### Configuration
The configuration system automatically creates necessary directories on first run.

- **Default Config**: `config/default.conf` contains default settings
- **User Config**: `~/.config/vdl4k/vdl4k.conf` (created on first run)
- **User Overrides**: `~/.config/vdl4k/config.sh` for personal customizations

To modify configuration:
1. Run `vdl4k` once to create the configuration directory
2. Edit `~/.config/vdl4k/vdl4k.conf` or create `config.sh` for overrides
3. Example: Add `DOWNLOAD_DIR="/path/to/your/folder"` to change download location

## Usage
```bash
# After installation, use from anywhere:
vdl4k https://youtu.be/VIDEO_ID

# Download with custom directory
vdl4k -d /path/to/downloads https://youtu.be/VIDEO_ID

# Download playlist
vdl4k -p https://youtube.com/playlist?list=PLAYLIST_ID

# Force re-download (ignore archive)
vdl4k -f https://youtu.be/VIDEO_ID

# Verbose output with yt-dlp details
vdl4k -v -s https://youtu.be/VIDEO_ID

# Show current configuration
vdl4k --config

# Show help
vdl4k --help

# Or use the portable version:
vdl4k-portable https://youtu.be/VIDEO_ID
vdl4k-portable --help
```

## What's New in v0.57

🚀 **Global Installation System** - Run `./install.sh` once and use `vdl4k` from anywhere on your system!

- ✅ **One-Command Installation**: `./install.sh` handles everything automatically
- ✅ **Global PATH Integration**: Adds `~/bin` to your shell configuration
- ✅ **Smart Module Detection**: Automatically finds and loads project modules
- ✅ **Dual Global Access**: Both modular and portable versions available globally
- ✅ **Dependency Checking**: Verifies yt-dlp, ffmpeg, and ffprobe are installed
- ✅ **Cross-Shell Support**: Works with both bash and zsh

## Two Versions Available

### Modular Version (`vdl4k`)
- **Recommended for development and customization**
- Multi-file structure with separate modules
- Easier to maintain and extend
- Requires full project structure
- **Available globally** after running `./install.sh`

### Portable Version (`vdl4k-portable`)
- **Recommended for end users and distribution**
- Single self-contained executable
- All modules embedded in one file
- Perfect for sharing and deployment
- **Available globally** after running `./install.sh`

## Configuration Options
| Option | Description | Default |
|--------|-------------|---------|
| `DOWNLOAD_DIR` | Directory where videos are downloaded | `~/Downloads/Videos Archive` |
| `FORMAT` | yt-dlp format string | Best quality up to 4K |
| `SUB_LANGS` | Subtitle languages | English |
| `VERBOSE` | Enable verbose output | false |
| `FORCE_DOWNLOAD` | Force re-download | false |
| `DISABLE_ARCHIVE` | Disable download tracking | false |

## Project Structure
```
vdl4k/
├── bin/
│   └── vdl4k          # Main executable (modular)
├── lib/
│   ├── config.sh      # Configuration management
│   ├── utils.sh       # Core utilities
│   ├── validators.sh  # Input validation
│   ├── video_utils.sh # Video processing
│   ├── archive.sh     # Download history
│   └── download.sh    # Download operations
├── config/
│   └── default.conf   # Default configuration
├── doc/               # Documentation
├── Makefile          # Development tasks
├── install.sh        # Installation script
└── vdl4k-portable    # Portable single-file version

# After installation with ./install.sh:
~/bin/
├── vdl4k            # Global modular version
└── vdl4k-portable   # Global portable version
```

## Development
```bash
# Run tests
make test

# Clean temporary files
make clean

# Setup for development
make install

# Show help
make help
```

**For Users:**
```bash
# Simple installation
./install.sh

# Now use from anywhere
vdl4k --help
vdl4k <URL>
```

## Version
v0.57

## Changelog

### v0.57 (Latest)
- ✨ **Global Installation System**: Added comprehensive installation script that installs vdl4k globally
- 🏠 **Smart PATH Integration**: Automatically adds `~/bin` to user PATH in `.bashrc` and `.zshrc`
- 🔍 **Intelligent Module Detection**: Wrapper script automatically locates project modules from anywhere
- 📁 **Enhanced Project Structure**: Updated documentation to reflect global installation workflow
- 🚀 **Improved User Experience**: One-command installation with dependency checking
- 📚 **Updated Documentation**: Enhanced README and flowcharts with installation flows

### v0.56
- 🏗️ **Complete Modular Architecture**: Refactored monolithic script into 6 specialized modules
- 📦 **Dual Deployment Options**: Both modular (development) and portable (single-file) versions
- ⚙️ **Advanced Configuration System**: Multi-tier configuration with precedence handling
- 🛡️ **Enhanced Error Handling**: Comprehensive validation and error reporting
- 📖 **Professional Documentation**: Complete README, architecture flowcharts, and development guides
- 🧪 **Automated Testing**: Makefile-based testing and development workflows

## License
MIT

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Issues and Support
- Report bugs via GitHub Issues
- Check the [Flowchart](FLOWCHART.md) for architecture details
- Review the [Goals](GOALS) for project objectives

---
