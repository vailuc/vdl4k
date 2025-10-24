# vdl4k Makefile
# Common development and maintenance tasks

.PHONY: help install clean test archive docs

help:
	@echo "vdl4k Development Tasks"
	@echo "======================="
	@echo "install    - Setup scripts and permissions"
	@echo "clean      - Remove temporary and generated files"
	@echo "test       - Run basic functionality tests"
	@echo "archive    - Update archived files"
	@echo "docs       - Show documentation"
	@echo "portable   - Create portable version"

install:
	@echo "Setting up vdl4k..."
	@chmod +x bin/vdl4k
	@chmod +x vdl4k-portable
	@chmod +x install.sh
	@echo "✓ Scripts made executable"
	@echo "Run './install.sh' for full setup"

clean:
	@echo "Cleaning up temporary files..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✓ Cleanup complete"

test:
	@echo "Testing vdl4k functionality..."
	@echo "1. Testing modular version:"
	@./bin/vdl4k --help | head -5
	@echo "2. Testing portable version:"
	@./vdl4k-portable --help | head -5
	@echo "3. Testing configuration:"
	@./bin/vdl4k --config | head -3
	@echo "✓ Tests complete"

archive:
	@echo "Updating archive..."
	@if [ -d ".idea" ]; then mv .idea archive/ide-files/; echo "✓ Moved IDE files to archive"; fi
	@echo "✓ Archive updated"

docs:
	@echo "Documentation:"
	@echo "README.md     - Main documentation"
	@echo "FLOWCHART.md  - Architecture diagrams"
	@echo "GOALS         - Project goals"
	@echo "Run './bin/vdl4k --help' for usage"

portable:
	@echo "Portable version is already built: vdl4k-portable"
	@echo "This is a self-contained version with all modules embedded"

# Default target
all: help
