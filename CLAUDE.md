# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Ruby CLI tool that organizes files based on extensions, keywords, regex patterns, and dates. The tool supports internationalization (English/Japanese) based on the `LANG` environment variable and stores per-directory configurations using MD5 hashes.

## Development Commands

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/tidy_file_organizer_spec.rb
bundle exec rspec spec/duplicate_detector_spec.rb
bundle exec rspec spec/date_organizer_spec.rb
```

### Linting
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Building and Installing
```bash
# Build gem
gem build tidy-file-organizer.gemspec

# Install locally
gem install ./tidy-file-organizer-*.gem

# Development mode (run without installing)
ruby -I lib ./exe/tidyify [command] [options]
```

### Testing with Sample Data
```bash
# Test with English filenames
ruby -I lib ./exe/tidyify setup spec/data/en
ruby -I lib ./exe/tidyify run spec/data/en --recursive

# Test with Japanese filenames
ruby -I lib ./exe/tidyify setup spec/data/ja
ruby -I lib ./exe/tidyify run spec/data/ja --recursive
```

## Architecture

### Core Components

- **CLI** (`lib/tidy_file_organizer/cli.rb`): Entry point that parses commands and arguments. Handles 5 main commands:
  - `setup` and `run`: Directory defaults to current directory if not specified
  - `organize-by-date`, `find-duplicates`, `remove-duplicates`: Directory is required
  - Options are parsed by checking for flags like `--dry-run`, `--recursive`/`-r`, `--pattern=<value>`, `--no-confirm`

- **Organizer** (`lib/tidy_file_organizer/organizer.rb`): Main orchestrator for file organization. Implements three-level priority system:
  1. Pattern matching (highest priority) - matches regex patterns in filename
  2. Keyword matching (high priority) - matches keywords anywhere in filename
  3. Extension matching (normal priority) - matches file extensions

- **Config** (`lib/tidy_file_organizer/config.rb`): Manages per-directory configuration using MD5 hash of directory path. Stores configs in `~/.config/tidy-file-organizer/[MD5hash].yml`. Supports default config references to avoid duplication.

- **I18n** (`lib/tidy_file_organizer/i18n.rb`): Internationalization system that auto-detects locale from `LANG` env var. Loads translations from `lib/tidy_file_organizer/locale/{en,ja}.yml`.

- **DateOrganizer** (`lib/tidy_file_organizer/date_organizer.rb`): Organizes files by modification date with three patterns: year, year-month, year-month-day.

- **DuplicateDetector** (`lib/tidy_file_organizer/duplicate_detector.rb`): Uses SHA-256 hashing to find and remove duplicate files. Supports interactive confirmation mode.

- **FileMover** (`lib/tidy_file_organizer/file_mover.rb`): Handles safe file movement with conflict detection and dry-run support.

- **FileHelper** (`lib/tidy_file_organizer/file_helper.rb`): Provides utilities for file collection, recursion, and path handling.

- **SetupPrompt** (`lib/tidy_file_organizer/setup_prompt.rb`): Interactive setup wizard that:
  1. Prompts for language preference (en/ja)
  2. Displays and accepts extension rules
  3. Displays and accepts keyword rules
  4. Provides language-specific default values in `default_extensions` and `default_keywords` methods

### Configuration System

Configurations are stored per-directory using MD5 hash of absolute path:
- Path: `~/.config/tidy-file-organizer/[MD5hash].yml`
- Default configs: `default.yml` (English), `default.ja.yml` (Japanese)
- If user config matches default, creates a reference file pointing to default instead of duplicating

Default configurations are sourced from `config/default.yml` and `config/default.ja.yml`.

**Configuration Format**:
```yaml
language: en  # or 'ja'
extensions:
  Images: [jpg, jpeg, png, gif, bmp, svg, webp, heic, heif, tiff, avif, ico, raw]
  Documents: [pdf, doc, docx, txt, md]
  Databases: [db, sqlite, sqlite3, sql]
  Fonts: [ttf, otf, woff, woff2]
  eBooks: [epub, mobi, azw]
  Logs: [log, out, err]
  Data: [csv, tsv, parquet]
keywords:
  Screenshots: [screenshot, スクリーンショット, スクショ]
  Invoices: [invoice, 請求書]
  Receipts: [receipt, 領収書, レシート]
  Reports: [report, 報告書, レポート]
  Templates: [template, テンプレート, sample]
patterns:
  ByDate:
  - pattern: '\d{4}-\d{2}-\d{2}'
    description: 'Date format: 2024-01-15'
  - pattern: '\d{8}'
    description: 'Date format: 20240115'
  Versions:
  - pattern: 'v\d+\.\d+\.\d+'
    description: 'Semantic version: v1.0.0'
  - pattern: '_v\d+'
    description: 'Version suffix: file_v2'
```

**Interactive Setup Input Format**: `extensions,list:directory keyword,list:directory`
- Example: `jpg,png:images pdf,doc:documents screenshot:screenshots`

**Language-Specific Defaults**: `SetupPrompt` maintains separate default configurations for English and Japanese. When language is set to 'ja', folder names use Japanese (e.g., '画像', '書類') while English uses 'Images', 'Documents'. Keywords include both languages to support bilingual file matching.

### Internationalization Flow

1. `I18n.locale` auto-detects from `LANG` environment variable (defaults to `:en`)
2. Translations loaded from `lib/tidy_file_organizer/locale/{locale}.yml`
3. All user-facing messages use `I18n.t('key.path')` for translation
4. Supports variable interpolation: `I18n.t('key', var: value)`

### File Organization Priority

When running `tidyify run`:
1. **Pattern matching** is checked first (regex patterns in filename) - highest priority
2. **Keyword matching** is checked second (entire filename) - high priority
3. **Extension matching** is checked third (file extension only) - normal priority
4. Files matching none of the above are skipped
5. Organized directories are excluded from processing to prevent reorganizing already-organized files

**Priority Example**:
- File: `invoice_2024-01-15.pdf`
- Pattern match: `\d{4}-\d{2}-\d{2}` → Goes to `ByDate/` folder
- Even though "invoice" keyword exists, pattern takes precedence

**Exclusion Mechanism**:
- `Organizer#extract_organized_dirs` collects all directory names from config (extensions, keywords, and patterns)
- In recursive mode, `FileHelper#excluded_path?` checks if any part of the file's relative path matches an organized directory name
- This prevents files like `images/photo.jpg` from being re-organized into `images/images/photo.jpg`
- Empty directories are automatically cleaned up after recursive organization (excluding the target directory and organized directories)

**Pattern Matching Details**:
- Patterns are defined as Ruby regular expressions in the config file
- Each pattern category can have multiple regex patterns
- Patterns are matched against the full filename (including extension)
- Invalid regex patterns are skipped with a warning message
- Pattern matching supports both string keys ('pattern') and symbol keys (:pattern) for flexibility

## Code Style

This project follows [Cookpad's Ruby Style Guide](https://github.com/cookpad/styleguide) via `.rubocop.cookpad-styleguide.yml` with project-specific overrides in `.rubocop.yml`.

## Requirements

- Ruby 3.0+
- Standard library only (yaml, fileutils, digest)
- Development dependencies: rspec, rubocop, rubocop-performance, rubocop-rspec
