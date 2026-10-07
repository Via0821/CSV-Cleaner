# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/validator"

class ValidatorTest < Minitest::Test
  def setup
    @validator = CsvCleaner::Validator.new
  end

  def test_問題がなければ警告は出ない
    row = { "氏名" => "田中 太郎", "メールアドレス" => "tanaka@example.com", "電話番号" => "09012345678" }

    assert_empty @validator.validate(row)
  end

  def test_メールアドレスの形式が不正な場合は警告する
    warnings = @validator.validate({ "メールアドレス" => "tanaka@example" })

    assert_equal 1, warnings.size
    assert_includes warnings.first, "「メールアドレス」の形式が正しくありません"
    assert_includes warnings.first, "tanaka@example"
  end

  def test_桁数が不正な電話番号は警告する
    assert_equal 1, @validator.validate({ "電話番号" => "0312" }).size
    assert_equal 1, @validator.validate({ "電話番号" => "819012345678" }).size
  end

  def test_国内番号は_10_桁と_11_桁を正しいとみなす
    assert_empty @validator.validate({ "電話番号" => "0312345678" })
    assert_empty @validator.validate({ "電話番号" => "09012345678" })
  end

  def test_国際番号は国番号付きでも正しいとみなす
    assert_empty @validator.validate({ "電話番号" => "+12025550143" })
  end

  def test_欠損値は警告しない
    assert_empty @validator.validate({ "メールアドレス" => nil, "電話番号" => nil })
  end

  def test_対象外の列は検証しない
    assert_empty @validator.validate({ "氏名" => "@@@", "備考" => "0312" })
  end

  def test_複数の列をまとめて検証する
    row = { "メールアドレス" => "tanaka@", "電話番号" => "12" }

    assert_equal 2, @validator.validate(row).size
  end
end
