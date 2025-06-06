# WTF-Tools: Developer Workflow Enhancement Scripts

A collection of 22 robust shell utility scripts designed to enhance developer productivity and solve common workflow challenges.

## Overview

WTF-Tools provides a comprehensive set of shell scripts that address specific development workflow challenges. Each script is:
- Robust and error-resistant
- Cross-platform compatible (Linux, macOS)
- Well-documented
- Easily installable and configurable

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/WTF-Tools.git
cd WTF-Tools

# Run the installation script
./install.sh
```

## Available Scripts

1. **env-setup**: Automatically setup .env from a template
2. **watch-run**: Watch files and re-run commands on changes
3. **zombie-killer**: Detect and terminate orphaned processes
4. **guess-dependency-manager**: Smart dependency manager detection
5. **postmortem**: Collect system state after crashes
6. **clear-dev-clutter**: Clean development artifacts
7. **killport-plus**: Enhanced port management
8. **venv-reset**: Reset Python virtual environments
9. **cross-shell-alias**: Sync aliases across shells
10. **tail-highlight**: Colorized log tailing
11. **watch-errors**: Error monitoring with notifications
12. **docker-prune-safe**: Safe Docker cleanup
13. **latency-check**: Network latency diagnostics
14. **secret-detector**: Security token scanner
15. **stash-manager**: Git stash management
16. **ssh-key-manager**: SSH key management
17. **smart-find**: Intelligent file search
18. **dead-code-detector**: Unused code finder
19. **build-cache-manager**: Build cache management
20. **license-checker**: Dependency license scanner
21. **commit-message-helper**: Smart commit message suggestions
22. **book**: Command bookmarking utility

## Usage

Each script includes detailed help documentation. Access it by running:

```bash
script-name --help
```

## Configuration

Scripts can be configured through:
- Environment variables
- Configuration files in `~/.config/wtf-tools/`
- Command-line arguments

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) for details. 