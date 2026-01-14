# テスト用データディレクトリ

このディレクトリには、`tidy-file-organizer` の動作確認用の空ファイルが含まれています。
ルートディレクトリ、1階層、2階層のフォルダに無秩序にファイルが配置されています。

## ディレクトリ構造

```
spec/data/
├── (ルート階層に26ファイル)
├── documents/           # 1階層フォルダ
│   ├── (3ファイル)
│   └── reports/        # 2階層フォルダ
│       └── (3ファイル)
├── images/             # 1階層フォルダ
│   ├── (3ファイル)
│   └── 2024/          # 2階層フォルダ
│       └── (3ファイル)
├── projects/           # 1階層フォルダ
│   ├── (3ファイル)
│   ├── frontend/      # 2階層フォルダ
│   │   └── (4ファイル)
│   └── backend/       # 2階層フォルダ
│       └── (4ファイル)
├── archives/           # 1階層フォルダ
│   ├── (2ファイル)
│   └── old/          # 2階層フォルダ
│       └── (3ファイル)
├── temp/              # 1階層フォルダ
│   └── (3ファイル)
└── logs/              # 1階層フォルダ
    └── (3ファイル)
```

合計: 約60ファイル

## Dry-run テストの実行方法

### 1. セットアップ（設定）
```bash
./exe/tidy-file-organizer setup spec/data
```

入力例：
- 拡張子ベース: `jpg,png,jpeg,gif:images pdf,docx,xlsx,txt,md:documents rb,py,js,html,css:scripts json,yml,zip,gz:archives log,tmp:logs`
- キーワードベース: `project_a:work_a project_b:work_b screenshot:screenshots invoice:billing`

### 2. Dry-run（シミュレーション）
```bash
./exe/tidy-file-organizer run spec/data
```

### 3. 実際の整理（--force オプション使用）
```bash
./exe/tidy-file-organizer run spec/data --force
```

## 注意
現在の実装では、ルート階層のファイルのみが整理対象です。
サブディレクトリ内のファイルは整理されません。
