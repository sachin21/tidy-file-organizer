# Changelog

## [1.0.3] - 2026-01-15

### Documentation
- Add LICENSE file with MIT License and CC BY 3.0 exception for RuboCop config
- Clarify license scope in README files (English and Japanese)
- Explicitly document that `.rubocop.cookpad-styleguide.yml` is not covered by MIT License

## [1.0.2] - 2026-01-15

### Fixed
- Downgrade Bundler version to 2.5.23 for CI compatibility

### Tests
- Rewrite RSpec tests in English
- Expand test data for Phase 1 and pattern matching
- Add comprehensive tests for Phase 1 and pattern matching

### Documentation
- Update architecture documentation and RuboCop configuration

## [1.0.1] - (Previous Release)

Initial release features:
- File organization based on extensions, keywords, and regex patterns
- Date-based file organization
- Duplicate file detection and removal
- Internationalization support (English/Japanese)
- Per-directory configuration management using MD5 hashes
