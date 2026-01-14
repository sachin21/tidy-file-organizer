# テスト用データディレクトリ

このディレクトリには、`tidy-file-organizer` の動作確認用の空ファイルが含まれています。
英語版 (en/) と日本語版 (ja/) の2つのテストデータセットがあります。

## ディレクトリ構造

```
spec/data/
├── en/                 # 英語ファイル名のテストデータ
│   ├── (ルート階層に26ファイル)
│   ├── documents/
│   │   ├── (3ファイル)
│   │   └── reports/        (3ファイル)
│   ├── images/
│   │   ├── (3ファイル)
│   │   └── 2024/          (3ファイル)
│   ├── projects/
│   │   ├── (3ファイル)
│   │   ├── frontend/      (4ファイル)
│   │   └── backend/       (4ファイル)
│   ├── archives/
│   │   ├── (2ファイル)
│   │   └── old/          (3ファイル)
│   ├── temp/              (3ファイル)
│   └── logs/              (3ファイル)
│
└── ja/                 # 日本語ファイル名のテストデータ
    ├── (ルート階層に26ファイル)
    ├── 書類/
    │   ├── (3ファイル)
    │   └── レポート/        (3ファイル)
    ├── 画像/
    │   ├── (3ファイル)
    │   └── 2024年/         (3ファイル)
    ├── プロジェクト/
    │   ├── (3ファイル)
    │   ├── フロントエンド/  (4ファイル)
    │   └── バックエンド/    (4ファイル)
    ├── アーカイブ/
    │   ├── (2ファイル)
    │   └── 古いファイル/    (3ファイル)
    ├── 一時/              (3ファイル)
    └── ログ/              (3ファイル)
```

合計: 約120ファイル (英語60 + 日本語60)

## Dry-run テストの実行方法

### 英語ファイルでテスト
```bash
# セットアップ
./exe/tidy-file-organizer setup spec/data/en

# 入力例（拡張子ベース）:
# jpg,png,jpeg,gif:images pdf,docx,xlsx,txt,md:documents rb,py,js,html,css:scripts json,yml,zip,gz:archives log,tmp:logs

# 入力例（キーワードベース）:
# project_a:work_a project_b:work_b screenshot:screenshots invoice:billing

# Dry-run
./exe/tidy-file-organizer run spec/data/en

# 実際に整理
./exe/tidy-file-organizer run spec/data/en --force
```

### 日本語ファイルでテスト
```bash
# セットアップ
./exe/tidy-file-organizer setup spec/data/ja

# 入力例（拡張子ベース）:
# jpg,png,jpeg,gif:画像 pdf,docx,xlsx,txt,md:書類 rb,py,js,html,css:スクリプト json,yml,zip,gz:アーカイブ log,tmp:ログ

# 入力例（キーワードベース）:
# プロジェクトA:作業A プロジェクトB:作業B スクリーンショット:スクショ 請求書:経理

# Dry-run
./exe/tidy-file-organizer run spec/data/ja

# 実際に整理
./exe/tidy-file-organizer run spec/data/ja --force
```

## 注意
現在の実装では、ルート階層のファイルのみが整理対象です。
サブディレクトリ内のファイルは整理されません。
