# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/report"

class ReportTest < Minitest::Test
  def setup
    @report = CsvCleaner::Report.new
  end

  def test_件数を集計して表示する
    @report.rows_read = 10
    @report.rows_written = 8
    @report.duplicates_removed = 2
    2.times { @report.record_change("空白の整形") }
    @report.record_change("電話番号")

    rendered = @report.render

    assert_includes rendered, "読み込み行数: 10 行"
    assert_includes rendered, "出力行数: 8 行"
    assert_includes rendered, "重複削除: 2 行"
    assert_includes rendered, "変更箇所: 3 件"
    assert_includes rendered, "空白の整形: 2 件"
    assert_includes rendered, "電話番号: 1 件"
  end

  def test_警告がなければ警告の行は出さない
    refute_includes @report.render, "警告"
  end

  def test_警告には行番号を添える
    @report.add_warning(3, "「メールアドレス」の形式が正しくありません (tanaka@example)")

    rendered = @report.render

    assert_includes rendered, "警告: 1 件"
    assert_includes rendered, "3行目: 「メールアドレス」の形式が正しくありません (tanaka@example)"
  end

  def test_警告が多い場合は件数をまとめて表示する
    15.times { |i| @report.add_warning(i + 2, "形式が正しくありません") }

    rendered = @report.render

    assert_includes rendered, "警告: 15 件"
    assert_includes rendered, "... ほか 5 件"
    assert_equal 10, rendered.lines.count { |line| line.include?("形式が正しくありません") }
  end
end
