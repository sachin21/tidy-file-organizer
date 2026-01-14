module TidyFileOrganizer
  module I18n
    class << self
      def locale
        @locale ||= detect_locale
      end

      def locale=(value)
        @locale = value
      end

      def t(key, **options)
        translations = locale == :ja ? TRANSLATIONS_JA : TRANSLATIONS_EN
        text = translations.dig(*key.to_s.split('.')) || key.to_s

        # Variable substitution
        options.each do |k, v|
          text = text.gsub("%{#{k}}", v.to_s)
        end

        text
      end

      private

      def detect_locale
        lang = ENV['LANG'].to_s
        lang.start_with?('ja') ? :ja : :en
      end
    end

    # English translations
    TRANSLATIONS_EN = {
      'setup' => {
        'title' => 'tidy-file-organizer Setup',
        'separator' => '=' * 60,
        'section_separator' => '-' * 60,
        'target_directory' => 'Target directory: %{dir}',
        'language_setting' => '[0] Folder Name Language Setting',
        'language_description' => 'Choose the language for organized folder names',
        'language_option_1' => '  1: English (e.g., Images, Documents, Screenshots)',
        'language_option_2' => '  2: Japanese (e.g., 画像, 書類, スクリーンショット)',
        'current_setting' => 'Current setting: %{setting}',
        'language_prompt' => 'Choose (1=English, 2=Japanese, Enter=keep current): ',
        'invalid_input' => 'Invalid input. Using default (English).',
        'extensions_title' => '[1] File Extension Rules',
        'extensions_description' => 'Specify destination folders based on file extensions',
        'keywords_title' => '[2] Keyword Rules',
        'keywords_description' => 'Specify destination folders based on keywords in filenames',
        'keywords_note' => '※Keywords have priority over extensions',
        'input_format' => 'Input format: extension_list:folder_name extension_list:folder_name ...',
        'default_values' => 'Default values:',
        'current_config' => 'Current config: %{config}',
        'new_config_prompt' => 'Enter new config (Enter to use defaults): ',
        'config_saved' => '✓ Configuration saved',
        'save_location' => '  Location: %{path}',
        'next_steps' => 'Next steps:',
        'step_dry_run' => '  1. Dry-run: tidyify run %{dir} --dry-run',
        'step_execute' => '  2. Execute: tidyify run %{dir}',
        'none' => 'none',
        'english' => 'English',
        'japanese' => 'Japanese',
      },
      'organizer' => {
        'no_config' => 'Configuration not found. Please run \'setup\' command first.',
        'starting' => '--- Starting organization (%{dir}) %{mode}  ---',
        'dry_run_mode' => '[Dry-run mode]',
        'recursive_mode' => '[Recursive mode]',
        'moved' => 'Moved: %{file} -> %{dest}',
        'dry_run_moved' => '[Dry-run] %{file} -> %{dest}',
        'cleaned_up' => 'Cleaned up: %{dir} (removed empty directory)',
        'no_files' => 'No files to organize.',
        'completed' => 'Organization completed.',
        'skip' => '[Skip] %{file} (already in correct location)',
      },
      'date_organizer' => {
        'starting' => '--- Starting date-based organization (%{dir}) %{mode}  ---',
        'pattern' => 'Pattern: %{pattern}',
        'invalid_pattern' => 'Invalid pattern: %{pattern}. Use year, year-month, or year-month-day.',
      },
      'duplicate_detector' => {
        'starting' => '--- Starting duplicate detection (%{dir}) ---',
        'file_count' => 'File count: %{count}',
        'calculating' => 'Calculating hashes...',
        'progress' => 'Progress: %{current}/%{total}',
        'result_title' => '=== Duplicate Detection Results ===',
        'duplicate_groups' => 'Duplicate groups: %{count}',
        'duplicate_files' => 'Duplicate files: %{count}',
        'no_duplicates' => 'No duplicates found.',
        'group_title' => '--- Group %{num} (%{count} files, hash: %{hash}...) ---',
        'file_size' => 'File size: %{size}',
        'wasted_space' => 'Wasted space: %{size}',
        'total_wasted' => 'Total wasted space: %{size}',
        'deletion_starting' => '--- Starting duplicate deletion %{mode} ---',
        'deletion_plan' => '--- Deletion Plan ---',
        'will_keep' => 'Keep: %{file}',
        'will_delete' => 'Delete: %{file} (%{size})',
        'kept' => 'Keep: %{file}',
        'deleted' => 'Delete: %{file} (%{size})',
        'confirm_deletion' => 'Delete these files? [yes/no]: ',
        'deletion_cancelled' => 'Deletion cancelled.',
        'invalid_response' => 'Invalid response. Please enter yes or no.',
        'summary' => '--- Summary ---',
        'deleted_count' => 'Deleted files: %{count}',
        'saved_space' => 'Saved disk space: %{size}',
        'confirm_header' => 'Duplicate File Deletion Confirmation',
        'confirm_separator' => '=' * 60,
        'files_to_delete' => 'Files to delete: %{count}',
        'space_to_save' => 'Disk space to save: %{size}',
        'files_list_title' => 'Files to delete:',
        'kept_file' => '   Kept file: %{file}',
        'executing_deletion' => 'Executing deletion...',
      },
      'cli' => {
        'error_directory_required' => 'Error: Please specify target directory',
        'usage' => 'Usage: tidyify [command] [target_directory] [options]',
        'commands' => 'Commands:',
        'cmd_setup' => '  setup              Set up organization rules interactively (defaults to current dir)',
        'cmd_run' => '  run                Organize files based on configuration (defaults to current dir)',
        'cmd_organize_date' => '  organize-by-date   Organize files by modification date',
        'cmd_find_dup' => '  find-duplicates    Find duplicate files',
        'cmd_remove_dup' => '  remove-duplicates  Remove duplicate files (keep first one)',
        'options' => 'Options:',
        'opt_dry_run' => '  --dry-run             Simulate without actual execution',
        'opt_recursive' => '  --recursive, -r       Process files in subdirectories recursively',
        'opt_pattern' => '  --pattern=<pattern>   Date pattern (year, year-month, year-month-day)',
        'opt_no_confirm' => '  --no-confirm          Skip confirmation before deletion (remove-duplicates only)',
        'examples' => 'Examples:',
        'ex_setup' => '  tidyify setup                                   # Set up current directory
  tidyify setup ~/Downloads                           # Set up specific directory',
        'ex_run_current' => '  tidyify run                                     # Organize current directory',
        'ex_run_dry' => '  tidyify run ~/Downloads --dry-run               # Dry-run',
        'ex_run_exec' => '  tidyify run ~/Downloads --recursive             # Execute',
        'ex_organize_date' => '  tidyify organize-by-date ~/Downloads --pattern=year-month',
        'ex_find_dup' => '  tidyify find-duplicates ~/Downloads --recursive',
        'ex_remove_dup' => '  tidyify remove-duplicates ~/Downloads --recursive',
        'ex_remove_no_confirm' => '  tidyify remove-duplicates ~/Downloads --no-confirm',
      },
      'post_install' => {
        'created_default_en' => '✓ Created default config file (English): %{path}',
        'created_default_ja' => '✓ Created default config file (Japanese): %{path}',
      },
    }.freeze

    # Japanese translations
    TRANSLATIONS_JA = {
      'setup' => {
        'title' => 'tidy-file-organizer セットアップ',
        'separator' => '=' * 60,
        'section_separator' => '-' * 60,
        'target_directory' => '対象ディレクトリ: %{dir}',
        'language_setting' => '[0] フォルダ名の言語設定',
        'language_description' => '整理先フォルダ名を日本語にするか英語にするか選択します',
        'language_option_1' => '  1: English (例: Images, Documents, Screenshots)',
        'language_option_2' => '  2: 日本語 (例: 画像, 書類, スクリーンショット)',
        'current_setting' => '現在の設定: %{setting}',
        'language_prompt' => '選択 (1=English, 2=日本語, Enter=現在の設定のまま): ',
        'invalid_input' => '無効な入力です。デフォルト（English）を使用します。',
        'extensions_title' => '[1] 拡張子による整理ルール',
        'extensions_description' => 'ファイルの拡張子に基づいて整理先フォルダを指定します',
        'keywords_title' => '[2] キーワードによる整理ルール',
        'keywords_description' => 'ファイル名に含まれるキーワードで整理先フォルダを指定します',
        'keywords_note' => '※キーワードは拡張子より優先されます',
        'input_format' => '入力形式: 拡張子リスト:フォルダ名 拡張子リスト:フォルダ名 ...',
        'default_values' => 'デフォルト値:',
        'current_config' => '現在の設定: %{config}',
        'new_config_prompt' => '新しい設定を入力 (デフォルト値を使う場合はEnter): ',
        'config_saved' => '✓ 設定を保存しました',
        'save_location' => '  保存先: %{path}',
        'next_steps' => '次のステップ:',
        'step_dry_run' => '  1. シミュレーション: tidyify run %{dir} --dry-run',
        'step_execute' => '  2. 実際に整理を実行: tidyify run %{dir}',
        'none' => 'なし',
        'english' => 'English',
        'japanese' => '日本語',
      },
      'organizer' => {
        'no_config' => '設定が見つかりません。先に \'setup\' コマンドを実行してください。',
        'starting' => '--- 整理を開始します (%{dir}) %{mode}  ---',
        'dry_run_mode' => '[Dry-run モード]',
        'recursive_mode' => '[再帰モード]',
        'moved' => 'Moved: %{file} -> %{dest}',
        'dry_run_moved' => '[Dry-run] %{file} -> %{dest}',
        'cleaned_up' => 'Cleaned up: %{dir} (空ディレクトリを削除)',
        'no_files' => '整理対象のファイルが見つかりませんでした。',
        'completed' => '整理が完了しました。',
        'skip' => '[Skip] %{file} (既に正しい場所にあります)',
      },
      'date_organizer' => {
        'starting' => '--- 日付ベースの整理を開始します (%{dir}) %{mode}  ---',
        'pattern' => '整理パターン: %{pattern}',
        'invalid_pattern' => '無効なパターン: %{pattern}。year, year-month, year-month-day のいずれかを使用してください。',
      },
      'duplicate_detector' => {
        'starting' => '--- 重複ファイルの検出を開始します (%{dir}) ---',
        'file_count' => 'ファイル数: %{count}',
        'calculating' => 'ハッシュ値を計算中...',
        'progress' => '進捗: %{current}/%{total}',
        'result_title' => '=== 重複ファイルの検出結果 ===',
        'duplicate_groups' => '重複グループ数: %{count}',
        'duplicate_files' => '重複ファイル数: %{count}',
        'no_duplicates' => '重複ファイルは見つかりませんでした。',
        'group_title' => '--- グループ %{num} (%{count} 件, ハッシュ: %{hash}...) ---',
        'file_size' => 'ファイルサイズ: %{size}',
        'wasted_space' => '無駄な容量: %{size}',
        'total_wasted' => '合計無駄容量: %{size}',
        'deletion_starting' => '--- 重複ファイルの削除を開始します %{mode} ---',
        'deletion_plan' => '--- 削除計画 ---',
        'will_keep' => '保持: %{file}',
        'will_delete' => '削除: %{file} (%{size})',
        'kept' => '保持: %{file}',
        'deleted' => '削除: %{file} (%{size})',
        'confirm_deletion' => 'これらのファイルを削除しますか？ [yes/no]: ',
        'deletion_cancelled' => '削除をキャンセルしました。',
        'invalid_response' => '無効な応答です。yes か no を入力してください。',
        'summary' => '--- サマリー ---',
        'deleted_count' => '削除されたファイル数: %{count}',
        'saved_space' => '節約されたディスク容量: %{size}',
        'confirm_header' => '重複ファイル削除の確認',
        'confirm_separator' => '=' * 60,
        'files_to_delete' => '削除対象のファイル数: %{count}',
        'space_to_save' => '節約されるディスク容量: %{size}',
        'files_list_title' => '削除対象のファイル:',
        'kept_file' => '   保持されるファイル: %{file}',
        'executing_deletion' => '削除を実行します...',
      },
      'cli' => {
        'error_directory_required' => 'エラー: 対象ディレクトリを指定してください',
        'usage' => 'Usage: tidyify [command] [target_directory] [options]',
        'commands' => 'Commands:',
        'cmd_setup' => '  setup              整理ルールをインタラクティブに設定します（ディレクトリ省略時はカレントディレクトリ）',
        'cmd_run' => '  run                設定に基づいてファイルを整理します（ディレクトリ省略時はカレントディレクトリ）',
        'cmd_organize_date' => '  organize-by-date   ファイルを更新日時ベースで整理します',
        'cmd_find_dup' => '  find-duplicates    重複ファイルを検出します',
        'cmd_remove_dup' => '  remove-duplicates  重複ファイルを削除します（最初のファイルを保持）',
        'options' => 'Options:',
        'opt_dry_run' => '  --dry-run             実際には実行せず、シミュレーションのみ行います',
        'opt_recursive' => '  --recursive, -r       サブディレクトリ内のファイルも再帰的に処理します',
        'opt_pattern' => '  --pattern=<pattern>   日付整理のパターン (year, year-month, year-month-day)',
        'opt_no_confirm' => '  --no-confirm          削除前の確認をスキップします（remove-duplicatesのみ）',
        'examples' => 'Examples:',
        'ex_setup' => '  tidyify setup                                   # Setup current directory
  tidyify setup ~/Downloads                           # Setup specific directory',
        'ex_run_current' => '  tidyify run                                     # Organize current directory',
        'ex_run_dry' => '  tidyify run ~/Downloads --dry-run               # Dry-run simulation',
        'ex_run_exec' => '  tidyify run ~/Downloads --recursive             # Execute with recursive',
        'ex_organize_date' => '  tidyify organize-by-date ~/Downloads --pattern=year-month',
        'ex_find_dup' => '  tidyify find-duplicates ~/Downloads --recursive',
        'ex_remove_dup' => '  tidyify remove-duplicates ~/Downloads --recursive',
        'ex_remove_no_confirm' => '  tidyify remove-duplicates ~/Downloads --no-confirm',
      },
      'post_install' => {
        'created_default_en' => '✓ デフォルト設定ファイル（英語）を作成しました: %{path}',
        'created_default_ja' => '✓ デフォルト設定ファイル（日本語）を作成しました: %{path}',
      },
    }.freeze
  end
end
