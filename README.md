# tidy-file-organizer

[![Ruby](https://img.shields.io/badge/Ruby-3.0+-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[日本語](README.ja.md)

A Ruby-based CLI tool to automatically organize files based on file names, folder names, and extensions.

## Features

- 🗂️ **Extension-based Organization**: Automatically classify by file types (images, documents, scripts, etc.)
- 🔍 **Keyword-based Organization**: Flexible classification by keywords in filenames (higher priority)
- 📅 **Date-based Organization**: Organize files by modification date (year, year-month, year-month-day)
- 🔍 **Duplicate Detection**: Find duplicate files using SHA-256 hash comparison
- 🗑️ **Duplicate Removal**: Automatically remove duplicate files while keeping one copy
- 🔄 **Recursive Mode**: Recursively organize files in subdirectories
- 🧪 **Dry-run Mode**: Simulate before actual execution (default)
- ⚠️ **Safe Execution**: Duplicate file detection, organized folder exclusion
- 🧹 **Auto Cleanup**: Automatically remove empty directories
- 🌏 **Japanese Support**: Full support for Japanese filenames and folder names
- ⚙️ **Flexible Configuration**: Save different organization rules per directory

## Installation

### Install as a Gem

```bash
gem build tidy-file-organizer.gemspec
gem install ./tidy-file-organizer-0.1.0.gem
```

### Use in Development

```bash
bundle install
ruby -I lib ./exe/tidy-file-organizer [command] [options]
```

## Usage

### 1. Setup (Configure Organization Rules)

```bash
tidy-file-organizer setup [directory_path]
```

Configure organization rules interactively:

```
[1] Extension-based Organization Rules
------------------------------------------------------------
Default values:
  jpg,jpeg,png,gif,bmp,svg,webp:images
  pdf,doc,docx,xls,xlsx,ppt,pptx,txt,md:documents
  rb,py,js,ts,java,cpp,c,go,rs:scripts
  ...

[2] Keyword-based Organization Rules
------------------------------------------------------------
Default values:
  screenshot:screenshots
  invoice:billing
  ...
```

### 2. Dry-run (Simulation)

```bash
# Root directory only
tidy-file-organizer run [directory_path]

# Including subdirectories
tidy-file-organizer run [directory_path] --recursive
```

Example output:
```
--- Starting organization (/path/to/dir) [Dry-run mode] [Recursive mode] ---
[Dry-run] photo1.jpg -> images/
[Dry-run] report.pdf -> documents/
[Dry-run] screenshot_2024.png -> screenshots/
⚠️  Conflict: image.jpg -> images/ (duplicate filename)
```

### 3. Execute Organization

```bash
# Execute with --force option if no issues
tidy-file-organizer run [directory_path] --force

# Combined with recursive mode
tidy-file-organizer run [directory_path] --recursive --force
```

## Command Reference

### Basic Organization
```
tidy-file-organizer setup [directory]              # Configure organization rules
tidy-file-organizer run [directory]                # Dry-run (simulation)
tidy-file-organizer run [directory] --force        # Actually execute organization
tidy-file-organizer run [directory] --recursive    # Include subdirectories
tidy-file-organizer run [directory] -r --force     # Execute in recursive mode
```

### Date-based Organization
```
# Organize by year (e.g., 2023/, 2024/)
tidy-file-organizer organize-by-date [directory] --pattern=year

# Organize by year-month (e.g., 2023-01/, 2023-06/)
tidy-file-organizer organize-by-date [directory] --pattern=year-month

# Organize by year-month-day (e.g., 2023-01-15/)
tidy-file-organizer organize-by-date [directory] --pattern=year-month-day --force
```

### Duplicate File Management
```
# Find duplicate files
tidy-file-organizer find-duplicates [directory] --recursive

# Remove duplicate files (keeps first file, deletes others)
# Interactive mode: Asks for confirmation before deletion
tidy-file-organizer remove-duplicates [directory] --recursive --force

# Skip confirmation with --no-confirm option
tidy-file-organizer remove-duplicates [directory] --recursive --force --no-confirm
```

**Note**: By default, `remove-duplicates` asks for confirmation with a [yes/no] prompt before deleting files. Use `--no-confirm` to skip this confirmation.

## Configuration Files

Configurations are saved in:

```
~/.config/tidy-file-organizer/[MD5hash].yml
```

Each directory maintains its own independent configuration.

## Example

### Before (Unorganized)
```
Downloads/
├── photo1.jpg
├── photo2.png
├── report.pdf
├── invoice_2024.pdf
├── script.rb
├── memo.txt
└── screenshot_2024.png
```

### After (Organized)
```
Downloads/
├── images/
│   ├── photo1.jpg
│   └── photo2.png
├── documents/
│   ├── report.pdf
│   └── memo.txt
├── screenshots/
│   └── screenshot_2024.png
├── billing/
│   └── invoice_2024.pdf
└── scripts/
    └── script.rb
```

## Development

### Run Tests

```bash
bundle exec rspec
```

### Try with Test Data

```bash
# English filenames
ruby -I lib ./exe/tidy-file-organizer setup spec/data/en
ruby -I lib ./exe/tidy-file-organizer run spec/data/en --recursive

# Japanese filenames
ruby -I lib ./exe/tidy-file-organizer setup spec/data/ja
ruby -I lib ./exe/tidy-file-organizer run spec/data/ja --recursive
```

## Technical Specifications

- **Language**: Ruby 3.0+
- **Standard Libraries**: yaml, fileutils, digest
- **Test Framework**: RSpec 3.0+
- **Configuration Format**: YAML

## License

MIT License

## Acknowledgments

This project uses [Cookpad's Ruby Style Guide](https://github.com/cookpad/styleguide) for RuboCop configuration, which is licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).

## Author

sachin21
