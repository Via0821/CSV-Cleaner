# frozen_string_literal: true

require_relative "../test_helper"
require "csv_cleaner/rules/normalize_email"

class NormalizeEmailTest < Minitest::Test
  def setup
    @rule = CsvCleaner::Rules::NormalizeEmail.new
  end

  def test_メールアドレスの列にだけ適用する
    assert @rule.applies_to?("メールアドレス")
    assert @rule.applies_to?("email")
    assert @rule.applies_to?("E-Mail")
    refute @rule.applies_to?("氏名")
    refute @rule.applies_to?("電話番号")
  end

  def test_小文字に揃える
    assert_equal "tanaka.taro@example.com", @rule.call("TANAKA.Taro@Example.COM")
  end

  def test_値の中の空白を取り除く
    assert_equal "tanaka@example.com", @rule.call("  tanaka @ example.com ")
  end

  def test_全角文字を半角に変換する
    assert_equal "tanaka@example.com", @rule.call("ｔａｎａｋａ＠ｅｘａｍｐｌｅ．ｃｏｍ")
  end

  def test_mailto_を取り除く
    assert_equal "tanaka@example.com", @rule.call("mailto:tanaka@example.com")
    assert_equal "tanaka@example.com", @rule.call("MAILTO:TANAKA@EXAMPLE.COM")
  end

  def test_山括弧を取り除く
    assert_equal "tanaka@example.com", @rule.call("<tanaka@example.com>")
  end

  def test_空になった値は_nil_になる
    assert_nil @rule.call("   ")
  end

  def test_nil_はそのまま返す
    assert_nil @rule.call(nil)
  end

  def test_形式が不正な値も整形だけ行う
    # 形式の判定は Validator が担当するため、ここでは値を捨てない
    assert_equal "tanaka@example", @rule.call("Tanaka@Example")
  end
end
