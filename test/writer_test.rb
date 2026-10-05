# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/table"
require "csv_cleaner/writer"

class WriterTest < Minitest::Test
  def test_ヘッダーとデータ行を書き出す
    in_tmpdir do |dir|
      path = File.join(dir, "output.csv")
      table = CsvCleaner::Table.new(%w[氏名 年齢], [{ "氏名" => "田中", "年齢" => "30" }])

      CsvCleaner::Writer.new(path).write(table)

      assert_equal "氏名,年齢\n田中,30\n", File.read(path)
    end
  end

  def test_nil_は空のセルとして書き出す
    in_tmpdir do |dir|
      path = File.join(dir, "output.csv")
      table = CsvCleaner::Table.new(%w[氏名 年齢], [{ "氏名" => "田中", "年齢" => nil }])

      CsvCleaner::Writer.new(path).write(table)

      assert_equal "氏名,年齢\n田中,\n", File.read(path)
    end
  end

  def test_区切り文字を含む値は引用符で囲む
    in_tmpdir do |dir|
      path = File.join(dir, "output.csv")
      table = CsvCleaner::Table.new(%w[会社名], [{ "会社名" => "株式会社テスト, 大阪支店" }])

      CsvCleaner::Writer.new(path).write(table)

      assert_equal %(会社名\n"株式会社テスト, 大阪支店"\n), File.read(path)
    end
  end

  def test_既存ファイルは上書きしない
    in_tmpdir do |dir|
      path = write_file(dir, "output.csv", "既存の内容\n")
      table = CsvCleaner::Table.new(%w[氏名], [])

      error = assert_raises(CsvCleaner::OutputError) { CsvCleaner::Writer.new(path).write(table) }

      assert_includes error.message, "--force"
      assert_equal "既存の内容\n", File.read(path)
    end
  end

  def test_force_を指定すると既存ファイルを上書きする
    in_tmpdir do |dir|
      path = write_file(dir, "output.csv", "既存の内容\n")
      table = CsvCleaner::Table.new(%w[氏名], [{ "氏名" => "田中" }])

      CsvCleaner::Writer.new(path, force: true).write(table)

      assert_equal "氏名\n田中\n", File.read(path)
    end
  end

  def test_出力先のディレクトリがない場合はエラーになる
    in_tmpdir do |dir|
      path = File.join(dir, "存在しない", "output.csv")
      table = CsvCleaner::Table.new(%w[氏名], [])

      error = assert_raises(CsvCleaner::OutputError) { CsvCleaner::Writer.new(path).write(table) }

      assert_includes error.message, "ディレクトリがありません"
    end
  end
end
