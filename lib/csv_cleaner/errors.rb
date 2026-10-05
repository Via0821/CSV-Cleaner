# frozen_string_literal: true

module CsvCleaner
  # 本ツールが意図的に発生させるエラーの基底クラス。
  # CLI はこのクラスを捕まえて、利用者向けのメッセージを表示する。
  class Error < StandardError; end

  # 入力 CSV が読み込めない、または形式が想定外の場合。
  class InputError < Error; end

  # 出力 CSV を書き出せない場合。
  class OutputError < Error; end

  # コマンドラインの指定方法が誤っている場合。
  class UsageError < Error; end
end
