# tidy-file-organizer

[![Ruby](https://img.shields.io/badge/Ruby-3.0+-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[English](README.md)

ファイル名、フォルダ名、拡張子などに基づいてファイルを自動的に整理するRuby製のCLIツールです。

## 特徴

- 🗂️ **拡張子ベースの整理**: 画像、書類、スクリプトなど、ファイルタイプごとに自動分類
- 🔍 **キーワードベースの整理**: ファイル名に含まれるキーワードで柔軟に分類（優先度：高）
- 📅 **日付ベースの整理**: ファイルの更新日時で整理（年、年月、年月日）
- 🔍 **重複検出**: SHA-256ハッシュ比較による重複ファイルの検出
- 🗑️ **重複削除**: 重複ファイルを自動削除（1つのコピーを保持）
- 🔄 **再帰モード**: サブディレクトリ内のファイルも再帰的に整理
- 🧪 **Dry-runモード**: --dry-runオプションでシミュレーション実行
- ⚠️ **安全な実行**: ファイル名重複の検知、整理済みフォルダの除外
- 🧹 **自動クリーンアップ**: 空になったディレクトリを自動削除
- 🌐 **国際化対応**: LANG環境変数に基づいた日本語/英語の完全サポート
- ⚙️ **柔軟な設定**: ディレクトリごとに異なる整理ルールを保存

## インストール

### Gemとしてインストール

```bash
gem build tidy-file-organizer.gemspec
gem install ./tidy-file-organizer-*.gem
```

**注意**: インストールメッセージは `LANG` 環境変数に基づいて日本語または英語で表示されます。

### 開発環境で使用

```bash
bundle install
ruby -I lib ./exe/tidyify [command] [options]
```

## 使い方

### 1. セットアップ（整理ルールの設定）

```bash
tidyify setup [ディレクトリパス]
# ディレクトリパスを省略した場合、カレントディレクトリを使用します
```

対話形式で整理ルールを設定します：

```
[1] 拡張子による整理ルール
------------------------------------------------------------
デフォルト値:
  jpg,jpeg,png,gif,bmp,svg,webp:画像
  pdf,doc,docx,xls,xlsx,ppt,pptx,txt,md:書類
  rb,py,js,ts,java,cpp,c,go,rs:スクリプト
  ...

[2] キーワードによる整理ルール
------------------------------------------------------------
デフォルト値:
  screenshot,スクリーンショット,スクショ:スクリーンショット
  invoice,請求書,見積:請求書
  ...
```

### 2. Dry-run（シミュレーション）

```bash
# ルートディレクトリのみ（シミュレーション）
tidyify run [ディレクトリパス] --dry-run
# ディレクトリパスを省略した場合、カレントディレクトリを使用します

# サブディレクトリも含めて（シミュレーション）
tidyify run [ディレクトリパス] --recursive --dry-run
```

実行例：
```
--- 整理を開始します (/path/to/dir) [Dry-run モード] [再帰モード] ---
[Dry-run] photo1.jpg -> 画像/
[Dry-run] report.pdf -> 書類/
[Dry-run] screenshot_2024.png -> スクリーンショット/
⚠️  Conflict: image.jpg -> 画像/ (ファイル名が重複しています)
```

### 3. 実際に整理を実行

```bash
# 整理を実行（実際にファイルを移動）
tidyify run [ディレクトリパス]
# ディレクトリパスを省略した場合、カレントディレクトリを使用します

# 再帰モードと組み合わせ
tidyify run [ディレクトリパス] --recursive
```

## コマンド一覧

### 基本的な整理
```
tidyify setup [directory]                    # 整理ルールを設定（省略時はカレントディレクトリ）
tidyify run [directory] --dry-run            # Dry-run（シミュレーション、省略時はカレントディレクトリ）
tidyify run [directory]                      # 実際に整理を実行（省略時はカレントディレクトリ）
tidyify run [directory] --recursive          # サブディレクトリも対象
tidyify run [directory] -r --dry-run         # 再帰モードでシミュレーション
```

### 日付ベースの整理
```
# 年ごとに整理（例: 2023/, 2024/）
# directoryを省略した場合、カレントディレクトリを使用します
tidyify organize-by-date [directory] --pattern=year

# 年月ごとに整理（例: 2023-01/, 2023-06/）
tidyify organize-by-date [directory] --pattern=year-month

# 実行前にシミュレーション
tidyify organize-by-date [directory] --pattern=year-month-day --dry-run
```

### 重複ファイル管理
```
# 重複ファイルを検出
# directoryを省略した場合、カレントディレクトリを使用します
tidyify find-duplicates [directory] --recursive

# 重複ファイルを削除（最初のファイルを保持、残りを削除）
# インタラクティブモード: 削除前に確認を求めます
tidyify remove-duplicates [directory] --recursive

# 確認をスキップする場合は --no-confirm オプションを使用
tidyify remove-duplicates [directory] --no-confirm

# 削除のシミュレーション
tidyify remove-duplicates [directory] --dry-run
```

**注意**: デフォルトでは、`remove-duplicates` コマンドはファイル削除前に [yes/no] で確認を求めます。確認をスキップする場合は `--no-confirm` オプションを使用してください。

## 設定ファイル

設定は以下のディレクトリに保存されます：

```
~/.config/tidy-file-organizer/[MD5ハッシュ].yml
```

各ディレクトリごとに独立した設定が保持されます。

## 動作例

### Before（整理前）
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

### After（整理後）
```
Downloads/
├── 画像/
│   ├── photo1.jpg
│   └── photo2.png
├── 書類/
│   ├── report.pdf
│   └── memo.txt
├── スクリーンショット/
│   └── screenshot_2024.png
├── 請求書/
│   └── invoice_2024.pdf
└── スクリプト/
    └── script.rb
```

## 開発

### テストの実行

```bash
bundle exec rspec
```

### テストデータで試す

```bash
# 英語ファイル名
ruby -I lib ./exe/tidyify setup spec/data/en
ruby -I lib ./exe/tidyify run spec/data/en --recursive

# 日本語ファイル名
ruby -I lib ./exe/tidyify setup spec/data/ja
ruby -I lib ./exe/tidyify run spec/data/ja --recursive
```

## 技術仕様

- **言語**: Ruby 3.0+
- **標準ライブラリ**: yaml, fileutils, digest
- **テストフレームワーク**: RSpec 3.0+
- **設定形式**: YAML

## ライセンス

MIT License

## 謝辞

本プロジェクトのRuboCop設定には、[Style guides in COOKPAD](https://github.com/cookpad/styleguide)を使用しています。このスタイルガイドは[CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)ライセンスの下で提供されています。

## 作者

sachin21
