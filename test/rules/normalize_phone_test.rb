# frozen_string_literal: true

require_relative "../test_helper"
require "csv_cleaner/rules/normalize_phone"

class NormalizePhoneTest < Minitest::Test
  def setup
    @rule = CsvCleaner::Rules::NormalizePhone.new
  end

  def test_電話番号の列にだけ適用する
    assert @rule.applies_to?("電話番号")
    assert @rule.applies_to?("携帯")
    assert @rule.applies_to?("phone")
    assert @rule.applies_to?("TEL")
    refute @rule.applies_to?("氏名")
    refute @rule.applies_to?("メールアドレス")
  end

  def test_ハイフンを取り除く
    assert_equal "09012345678", @rule.call("090-1234-5678")
  end

  def test_空白や括弧を取り除く
    assert_equal "0312345678", @rule.call("(03) 1234 5678")
  end

  def test_全角数字を半角に変換する
    assert_equal "09011112222", @rule.call("０９０−１１１１−２２２２")
  end

  def test_日本の国際表記は国内表記に直す
    assert_equal "08098765432", @rule.call("+81 80-9876-5432")
  end

  def test_日本以外の国際表記は国番号を残す
    assert_equal "+12025550143", @rule.call("+1 202-555-0143")
  end

  def test_整形済みの値は変化しない
    assert_equal "09012345678", @rule.call("09012345678")
  end

  def test_数字がない値は_nil_になる
    assert_nil @rule.call("内線のみ")
  end

  def test_nil_はそのまま返す
    assert_nil @rule.call(nil)
  end

  def test_桁数が足りない値も整形だけ行う
    # 桁数の判定は Validator が担当する
    assert_equal "0312", @rule.call("0312")
  end
end
