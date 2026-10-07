# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/processor"
require "csv_cleaner/table"

class ProcessorTest < Minitest::Test
  def setup
    @processor = CsvCleaner::Processor.new
  end

  def test_整形してから重複を取り除く
    # 表記が違うだけの 2 行は、整形後に同じ内容になるため重複として扱われる
    table = CsvCleaner::Table.new(
      ["氏名", "メールアドレス"],
      [
        { "氏名" => " 田中 太郎 ", "メールアドレス" => "TANAKA@Example.com" },
        { "氏名" => "田中　太郎", "メールアドレス" => "tanaka@example.com" }
      ]
    )

    result = @processor.process(table)

    assert_equal [{ "氏名" => "田中 太郎", "メールアドレス" => "tanaka@example.com" }], result.table.rows
    assert_equal 1, result.report.duplicates_removed
  end

  def test_ヘッダーはそのまま引き継ぐ
    table = CsvCleaner::Table.new(["氏名"], [{ "氏名" => "田中" }])

    assert_equal ["氏名"], @processor.process(table).table.headers
  end

  def test_処理件数をレポートに記録する
    table = CsvCleaner::Table.new(
      ["氏名"],
      [{ "氏名" => " 田中 " }, { "氏名" => "田中" }, { "氏名" => "佐藤" }]
    )

    report = @processor.process(table).report

    assert_equal 3, report.rows_read
    assert_equal 2, report.rows_written
    assert_equal 1, report.duplicates_removed
    assert_equal 1, report.changes["空白の整形"]
  end

  def test_形式が不正な値は警告しつつ出力に残す
    table = CsvCleaner::Table.new(
      ["メールアドレス"],
      [{ "メールアドレス" => "tanaka@example.com" }, { "メールアドレス" => "sato@example" }]
    )

    result = @processor.process(table)

    assert_equal 2, result.table.rows.size
    assert_equal 1, result.report.warnings.size
    assert_includes result.report.warnings.first, "3行目"
  end

  def test_データ行がなくてもエラーにならない
    table = CsvCleaner::Table.new(["氏名"], [])

    result = @processor.process(table)

    assert_empty result.table.rows
    assert_equal 0, result.report.rows_read
  end
end
