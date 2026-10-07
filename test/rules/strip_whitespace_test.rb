# frozen_string_literal: true

require_relative "../test_helper"
require "csv_cleaner/rules/strip_whitespace"

class StripWhitespaceTest < Minitest::Test
  def setup
    @rule = CsvCleaner::Rules::StripWhitespace.new
  end

  def test_すべての列に適用する
    assert @rule.applies_to?("氏名")
    assert @rule.applies_to?("なんでも")
  end

  def test_前後の空白を取り除く
    assert_equal "田中 太郎", @rule.call("  田中 太郎  ")
  end

  def test_全角スペースも空白として扱う
    assert_equal "田中 太郎", @rule.call("　田中　太郎　")
  end

  def test_連続した空白を_1_つにまとめる
    assert_equal "株式会社 サンプル", @rule.call("株式会社   サンプル")
  end

  def test_タブと改行も取り除く
    assert_equal "メモ 1", @rule.call("\tメモ\n1\n")
  end

  def test_空白だけの値は空文字になる
    assert_equal "", @rule.call("   ")
  end

  def test_nil_はそのまま返す
    assert_nil @rule.call(nil)
  end

  def test_整形の必要がない値は変化しない
    assert_equal "田中 太郎", @rule.call("田中 太郎")
  end
end
