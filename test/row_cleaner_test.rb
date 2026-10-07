# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/row_cleaner"

class RowCleanerTest < Minitest::Test
  def setup
    @cleaner = CsvCleaner::RowCleaner.new
  end

  def test_列ごとに対応するルールを適用する
    row = {
      "氏名" => "  田中　太郎 ",
      "メールアドレス" => "TANAKA@Example.com",
      "電話番号" => "090-1234-5678",
      "備考" => "-"
    }

    result = @cleaner.clean(row)

    assert_equal "田中 太郎", result.row["氏名"]
    assert_equal "tanaka@example.com", result.row["メールアドレス"]
    assert_equal "09012345678", result.row["電話番号"]
    assert_nil result.row["備考"]
  end

  def test_変更があったルールのラベルを記録する
    row = { "氏名" => " 田中 ", "メールアドレス" => "TANAKA@example.com" }

    result = @cleaner.clean(row)

    assert_equal ["空白の整形", "メールアドレス"], result.changed_labels
  end

  def test_変更がなければラベルは記録されない
    row = { "氏名" => "田中 太郎", "メールアドレス" => "tanaka@example.com" }

    result = @cleaner.clean(row)

    assert_empty result.changed_labels
  end

  def test_空白を取り除いた結果が欠損値として扱われる
    result = @cleaner.clean({ "備考" => "  " })

    assert_nil result.row["備考"]
  end

  def test_元の行を書き換えない
    row = { "氏名" => " 田中 " }

    @cleaner.clean(row)

    assert_equal " 田中 ", row["氏名"]
  end

  def test_列の並び順は変わらない
    row = { "氏名" => "田中", "メールアドレス" => "tanaka@example.com", "備考" => "メモ" }

    assert_equal row.keys, @cleaner.clean(row).row.keys
  end

  def test_ルールを差し替えられる
    rule = Class.new do
      def label
        "大文字化"
      end

      def applies_to?(header)
        header == "氏名"
      end

      def call(value)
        value.upcase
      end
    end

    result = CsvCleaner::RowCleaner.new([rule.new]).clean({ "氏名" => "tanaka", "備考" => " メモ " })

    assert_equal "TANAKA", result.row["氏名"]
    assert_equal " メモ ", result.row["備考"]
    assert_equal ["大文字化"], result.changed_labels
  end
end
