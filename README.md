# 🛠️ WTF-Tools: Developer Workflow Enhancement Scripts

A collection of 10 robust shell utility scripts designed to enhance developer productivity and solve common workflow challenges.

## 📋 Overview

WTF-Tools provides a comprehensive set of shell scripts that address specific development workflow challenges. Each script is:

- ✅ Robust and error-resistant
- 🌐 Cross-platform compatible (Linux, macOS)
- 📝 Well-documented
- 🔄 Easily installable and configurable

## 💻 Installation

```bash
# Clone the repository
git clone https://github.com/Araise25/WTF-Tools.git
cd WTF-Tools

# Run the installation script
./install.sh
```

---

### 🔧 Recommended: Install Araise PM

To install multiple CLI tools like WTF-Tools with ease, we recommend using [Araise PM](https://github.com/Araise25/Araise_PM), a cross-platform package manager for developer tools.

Install Araise PM with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Araise25/Araise_PM/main/unix/install.sh | bash
```

Then install WTF-Tools via:

```bash
araise install wtf-tools
```

---

## 🧰 Available Scripts

### 1. 🧟 zombie-killer

**Function**: Detects and terminates orphaned or zombie processes spawned by broken dev tools.
**WTF Solved**: Dev server or Docker container crashed, but the process is still alive.
**Usage**: `zombie-killer`

### 2. 🔍 guess-dependency-manager

**Function**: Figures out whether to use npm, yarn, pnpm, pip, poetry, etc.
**WTF Solved**: "Which one did we use in this project again?"
**Usage**: `guess-dependency-manager install`

### 3. 🔬 postmortem

**Function**: After a crash, collects logs, running processes, open ports, memory usage.
**WTF Solved**: Post-crash chaos — you have no idea what just happened.
**Usage**: `postmortem` → saves to `postmortem_report.txt`

### 4. 🚫 killport-plus

**Function**: Like `killport` but also shows process name, source file, and asks before kill.
**WTF Solved**: "Oh no, I killed the wrong server again."
**Usage**: `killport-plus 3000`

### 5. 🔆 tail-highlight

**Function**: Tails a log and highlights error/warning/failure keywords in color.
**WTF Solved**: "I’m tailing logs but can’t spot the errors fast enough."
**Usage**: `tail-highlight /var/log/myapp.log`

### 6. ⚡ latency-check

**Function**: Pings common services (Google, GitHub, registry.npmjs.org) and shows response times.
**WTF Solved**: "Is my network slow or are THEY slow?"
**Usage**: `latency-check`

### 7. 📦 stash-manager

**Function**: Lists all Git stashes with diffs and lets you preview and delete interactively.
**WTF Solved**: “I have 15 stashes and no clue what they are.”
**Usage**: `stash-manager`

### 8. 🔑 ssh-key-manager

**Function**: Lists, generates, and manages SSH keys for different services
**WTF Solved**: "Which SSH key goes with which service again?"
**Usage**: `ssh-key-manager add github`

### 9. 🗑️ build-cache-manager

**Function**: Manages build caches across projects with size limits
**WTF Solved**: "Build caches are eating 50GB of disk space"
**Usage**: `build-cache-manager clean --older-than 7days`

### 10. 📚 book

**Function**: A smart CLI utility that bookmarks frequently forgotten shell commands. It allows developers to save, list, search, and re-run previous commands with ease.
**WTF Solved**: "I just figured out that perfect curl command to test this API, now it’s gone from my history 😩"
**Usage**: `book`

---

## 🚀 Usage

Each script includes detailed help documentation. Access it by running:

```bash
script-name --help
```

## 👥 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.
