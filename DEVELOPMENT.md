# vdl4k Development Workflow

This document outlines the standard development workflow for contributing features and improvements to vdl4k.

## 🚀 Quick Start

For new features, always start with:
```bash
git pull origin main
git checkout -b feature/your-feature-name
# ... develop and test ...
git push origin feature/your-feature-name
git checkout main && git merge feature/your-feature-name
git push origin main
```

## 📋 Development Process

### 1. Preparation
- **Update local repository**: `git pull origin main`
- **Create feature branch**: `git checkout -b feature/feature-name`
- **Verify setup**: `make test` and `./bin/vdl4k --help`

### 2. Development
- Make your code changes
- Test thoroughly with various scenarios
- Update documentation if needed
- Run `make test` to verify functionality

### 3. Commit and Push
- **Stage changes**: `git add .`
- **Commit with descriptive message**: `git commit -m "feat: description"`
- **Push feature branch**: `git push origin feature/feature-name`

### 4. Integration
- **Switch to main**: `git checkout main`
- **Merge feature**: `git merge feature/feature-name`
- **Push to main**: `git push origin main`

## 🏷️ Branch Naming Conventions

### Feature Branches
```
feature/xdg-compliance              # New features
feature/improved-validation         # Enhancements
feature/better-error-handling       # Improvements
feature/playlist-download           # New capabilities
```

### Bug Fix Branches
```
fix/path-detection-bug              # Bug fixes
fix/installation-error              # Installation fixes
hotfix/critical-security            # Urgent security fixes
```

### Release Branches
```
release/v0.58                       # Release preparation
release/v0.59                       # Future releases
```

### Maintenance Branches
```
chore/update-dependencies           # Maintenance tasks
docs/update-installation            # Documentation changes
refactor/code-cleanup               # Code refactoring
```

## 💬 Commit Message Standards

Use conventional commit format:

### Feature Commits
```bash
feat: Add enhanced playlist download support
feat: Implement XDG Base Directory compliance
feat: Add cross-shell PATH integration
```

### Bug Fixes
```bash
fix: Resolve PATH detection issue on some systems
fix: Fix installation script duplicate entries
fix: Correct wrapper script module loading
```

### Documentation
```bash
docs: Update installation guide for XDG compliance
docs: Add architecture flow diagrams
docs: Improve README with troubleshooting section
```

### Code Changes
```bash
refactor: Simplify PATH detection logic
chore: Update dependencies and clean up imports
style: Format code and improve readability
```

## 🧪 Testing Requirements

### Before Committing
1. **Basic functionality**: `./bin/vdl4k --help`
2. **Configuration**: `./bin/vdl4k --config`
3. **Installation**: `./install.sh` (test full installation)
4. **Cross-shell**: Test with both bash and zsh
5. **Edge cases**: Test error conditions and unusual inputs

### Automated Testing
```bash
make test              # Run full test suite
make clean             # Clean up temporary files
./bin/vdl4k --version  # Verify version consistency
```

## 📚 Documentation Updates

When adding new features, update:

### Required Documentation
- **README.md**: Feature description and usage examples
- **FLOWCHART.md**: Update architecture diagrams
- **Installation Guide**: Update installation instructions
- **Changelog**: Add entry in version changelog

### Documentation Checklist
- [ ] Feature described in README
- [ ] Installation instructions updated
- [ ] Architecture diagrams current
- [ ] Code examples work correctly
- [ ] Troubleshooting section updated

## 🔄 Release Process

### For Version Releases
1. **Create release branch**: `git checkout -b release/v0.XX`
2. **Update version numbers** in all relevant files
3. **Update changelog** with new features
4. **Test thoroughly** including installation
5. **Merge to main**: `git checkout main && git merge release/v0.XX`
6. **Push release**: `git push origin main`

### Version Update Files
- `README.md` - Version number and changelog
- `bin/vdl4k` - Version header and script metadata
- `vdl4k-portable` - Version header
- `install.sh` - Version in wrapper script
- `FLOWCHART.md` - Version in diagrams

## 👥 Collaboration Workflow

### For Solo Development
- Use feature branches for significant changes
- Work directly on main for small fixes
- Regular commits with descriptive messages
- Push frequently to maintain backup

### For Multiple Contributors
1. **Contributors fork** the repository
2. **Create feature branches** in their fork
3. **Submit Pull Requests** to main branch
4. **Review and merge** via GitHub interface
5. **Maintain clean main branch** at all times

## 🛠️ Development Tools

### Essential Commands
```bash
git status                    # Check current status
git log --oneline --graph     # View commit history
git diff                      # See changes
git branch -a                 # List all branches
git remote -v                 # Check remote repositories
```

### Useful Aliases
```bash
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.st "status --short"
git config --global alias.co "checkout"
git config --global alias.br "branch"
```

## 📝 Code Standards

### Shell Scripts
- Use `#!/bin/bash` shebang
- Set strict options: `set -o nounset -o pipefail`
- Include error handling and validation
- Add comments for complex logic
- Test with shellcheck

### Documentation
- Clear, concise language
- Working code examples
- Update related documentation
- Include troubleshooting section

## 🚨 Emergency Procedures

### If Something Goes Wrong
```bash
git status                    # Check current state
git diff                      # See what changed
git log --oneline -5          # Recent commits
git reset --hard origin/main  # Reset to remote main (CAREFUL!)
```

### Reverting Changes
```bash
git revert HEAD               # Revert last commit
git reset --hard HEAD~1       # Remove last commit (CAREFUL!)
git checkout -- <file>        # Restore specific file
```

## 📊 Project Structure Reminder

```
vdl4k/
├── bin/vdl4k              # Main modular version
├── lib/                   # Core modules
│   ├── config.sh          # Configuration management
│   ├── utils.sh           # Utilities and helpers
│   ├── validators.sh      # Input validation
│   ├── video_utils.sh     # Video processing
│   ├── archive.sh         # Download tracking
│   └── download.sh        # Download operations
├── config/                # Configuration files
├── doc/                   # Documentation
├── install.sh             # Installation script
├── vdl4k-portable         # Portable version
├── Makefile               # Development tasks
├── README.md              # Project documentation
├── FLOWCHART.md           # Architecture diagrams
└── GOALS                  # Project objectives
```

## ✅ Quality Checklist

Before merging any feature:

- [ ] **Functionality**: Feature works as intended
- [ ] **Testing**: All tests pass (`make test`)
- [ ] **Documentation**: README and docs updated
- [ ] **Installation**: Installation script works
- [ ] **Cross-platform**: Works with bash and zsh
- [ ] **Edge cases**: Error handling tested
- [ ] **Code quality**: Follows project standards

## 📞 Getting Help

- Check existing documentation in `doc/` directory
- Review commit history: `git log --oneline --grep="feature"`
- Test installation: `./install.sh` and verify functionality
- Check GitHub Issues for similar problems

---

**Remember**: Clean code, clear documentation, and thorough testing make vdl4k better for everyone! 🚀
