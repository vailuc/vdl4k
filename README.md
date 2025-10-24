# vdl4k

A robust YouTube/other video downloader with 4K support built with a modular architecture. The goal of this script is to archive videos seen on a page for personal use, providing an easy way to download and organize high-quality videos while maintaining a download history and supporting batch processing.

## Features
- 4K video support with fallback options
- Automatic resolution comparison and upgrade
- Category-based organization
- Comprehensive logging
- Clipboard URL detection
- Configurable settings
- Modular architecture with separate utility modules
- Robust error handling and validation

## Architecture
vdl4k is built with a modular architecture consisting of:

- **bin/vdl4k**: Main executable script
- **lib/utils.sh**: Core utilities and helper functions
- **lib/validators.sh**: URL and input validation
- **lib/video_utils.sh**: Video processing functions
- **lib/archive.sh**: Download history management
- **lib/download.sh**: Video download and processing
- **lib/config.sh**: Configuration management

## Installation

### Prerequisites
Ensure the following tools are installed on your system:
- **yt-dlp**: Video downloader (install via pip: `pip install yt-dlp` or package manager)
- **ffmpeg**: For video processing (install via `sudo apt install ffmpeg` on Ubuntu/Debian)
- **ffprobe**: Included with ffmpeg
- **xsel** (optional): For clipboard support on Linux (install via `sudo apt install xsel`)

### Quick Install
1. Clone the repository: `git clone <repository-url>`
2. Navigate to the project directory: `cd vdl4k`
3. Run the installation script: `./install.sh`
4. Make scripts executable: `make install` or `chmod +x bin/vdl4k vdl4k-portable`

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
# Basic download
./bin/vdl4k https://youtu.be/VIDEO_ID

# Download with custom directory
./bin/vdl4k -d /path/to/downloads https://youtu.be/VIDEO_ID

# Download playlist
./bin/vdl4k -p https://youtube.com/playlist?list=PLAYLIST_ID

# Force re-download (ignore archive)
./bin/vdl4k -f https://youtu.be/VIDEO_ID

# Verbose output with yt-dlp details
./bin/vdl4k -v -s https://youtu.be/VIDEO_ID

# Show current configuration
./bin/vdl4k --config

# Show help
./bin/vdl4k --help
```

## Two Versions Available

### Modular Version (`bin/vdl4k`)
- **Recommended for development and customization**
- Multi-file structure with separate modules
- Easier to maintain and extend
- Requires full project structure

### Portable Version (`vdl4k-portable`)
- **Recommended for end users and distribution**
- Single self-contained executable
- All modules embedded in one file
- Perfect for sharing and deployment

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
```

## Development
```bash
# Run tests
make test

# Clean temporary files
make clean

# Show help
make help
```

## Version
v0.56

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

**Ready for GitHub!** This repository contains both modular and portable versions, comprehensive documentation, and development tools for easy contribution and maintenance.
