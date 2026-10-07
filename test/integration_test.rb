# frozen_string_literal: true

require_relative "test_helper"
require "csv"
require "csv_cleaner"

# 同梱のサンプルデータを実際に処理して、全体が通しで動くことを確認する。
class IntegrationTest < Minitest::Test
  EXAMPLE_PATH = File.expand_path("../examples/messy_contacts.csv", __dir__)

  def test_サンプルデータを整形できる
    in_tmpdir do |dir|
      output = File.join(dir, "cleaned.csv")
      out = StringIO.new

      assert_equal 0, CsvCleaner::CLI.run([EXAMPLE_PATH, output], out: out, err: StringIO.new)

      rows = CSV.read(output, headers: true)
      assert_equal %w[氏名 メールアドレス 電話番号 会社名 備考], rows.headers
      # 12 行のうち、整形後に同じ内容になる 2 行が取り除かれる
      assert_equal 10, rows.size

      assert_includes out.string, "読み込み行数: 12 行"
      assert_includes out.string, "重複削除: 2 行"
    end
  end

  def test_整形後の値がすべて正規形になっている
    in_tmpdir do |dir|
      output = File.join(dir, "cleaned.csv")
      CsvCleaner::CLI.run([EXAMPLE_PATH, output], out: StringIO.new, err: StringIO.new)

      CSV.foreach(output, headers: true) do |row|
        assert_equal row["氏名"], row["氏名"].strip
        assert_equal row["メールアドレス"], row["メールアドレス"].downcase if row["メールアドレス"]
        assert_match(/\A\+?\d+\z/, row["電話番号"]) if row["電話番号"]
      end
    end
  end

  def test_欠損値のプレースホルダーが空のセルになっている
    in_tmpdir do |dir|
      output = File.join(dir, "cleaned.csv")
      CsvCleaner::CLI.run([EXAMPLE_PATH, output], out: StringIO.new, err: StringIO.new)

      values = CSV.read(output, headers: true).map { |row| row["備考"] }.compact

      refute_includes values, "-"
      refute_includes values, "N/A"
      refute_includes values, "なし"
    end
  end
end
