# CSV Cleaner

CSV の表記ゆれと重複を整えて、きれいな CSV を書き出すコマンドラインツールです。

現在開発中です。まずは CSV の読み書きと、読み込めないファイルの扱いを実装しています。

## 動作環境

- Ruby 3.1 以上（開発・動作確認は 3.4.11）
- 入力は UTF-8（BOM 付きも可）でヘッダー行のある CSV

## 開発

```console
$ bundle install
$ bundle exec rake test
```

## ライセンス

[MIT License](LICENSE)
