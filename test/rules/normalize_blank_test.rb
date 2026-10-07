# frozen_string_literal: true

require_relative "../test_helper"
require "csv_cleaner/rules/normalize_blank"

class NormalizeBlankTest < Minitest::Test
  def setup
    @rule = CsvCleaner::Rules::NormalizeBlank.new
  end

  def test_空文字は_nil_になる
    assert_nil @rule.call("")
  end

  def test_ハイフンだけの値は_nil_になる
    assert_nil @rule.call("-")
    assert_nil @rule.call("--")
    assert_nil @rule.call("ー")
  end

  def test_欠損値を表す英語表記は大文字小文字を問わず_nil_になる
    assert_nil @rule.call("N/A")
    assert_nil @rule.call("n/a")
    assert_nil @rule.call("NULL")
  end

  def test_欠損値を表す日本語表記も_nil_になる
    assert_nil @rule.call("なし")
    assert_nil @rule.call("不明")
  end

  def test_前後に空白があっても判定できる
    assert_nil @rule.call(" - ")
  end

  def test_nil_はそのまま_nil_を返す
    assert_nil @rule.call(nil)
  end

  def test_意味のある値はそのまま返す
    assert_equal "0", @rule.call("0")
    assert_equal "要確認", @rule.call("要確認")
    assert_equal "ニール", @rule.call("ニール")
  end
end
