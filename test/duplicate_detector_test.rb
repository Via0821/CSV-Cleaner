# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/duplicate_detector"

class DuplicateDetectorTest < Minitest::Test
  def setup
    @detector = CsvCleaner::DuplicateDetector.new
  end

  def test_全列が一致する行を重複とみなす
    rows = [
      { "氏名" => "田中", "年齢" => "30" },
      { "氏名" => "佐藤", "年齢" => "25" },
      { "氏名" => "田中", "年齢" => "30" }
    ]

    result = @detector.split(rows)

    assert_equal [{ "氏名" => "田中", "年齢" => "30" }, { "氏名" => "佐藤", "年齢" => "25" }], result.unique_rows
    assert_equal [{ "氏名" => "田中", "年齢" => "30" }], result.duplicate_rows
  end

  def test_最初に現れた行を残す
    rows = [{ "氏名" => "田中", "備考" => "1 件目" }, { "氏名" => "田中", "備考" => "1 件目" }]

    assert_equal "1 件目", @detector.split(rows).unique_rows.first["備考"]
  end

  def test_一部の列が違う行は重複ではない
    rows = [{ "氏名" => "田中", "年齢" => "30" }, { "氏名" => "田中", "年齢" => "31" }]

    result = @detector.split(rows)

    assert_equal 2, result.unique_rows.size
    assert_empty result.duplicate_rows
  end

  def test_nil_と空文字は同じ値として扱う
    rows = [{ "氏名" => "田中", "備考" => nil }, { "氏名" => "田中", "備考" => "" }]

    assert_equal 1, @detector.split(rows).unique_rows.size
  end

  def test_同じ行が_3_つ以上あっても_1_つだけ残す
    rows = Array.new(3) { { "氏名" => "田中" } }

    result = @detector.split(rows)

    assert_equal 1, result.unique_rows.size
    assert_equal 2, result.duplicate_rows.size
  end

  def test_空の入力は空の結果を返す
    result = @detector.split([])

    assert_empty result.unique_rows
    assert_empty result.duplicate_rows
  end
end
