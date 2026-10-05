# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/reader"

class ReaderTest < Minitest::Test
  def test_ヘッダーとデータ行を読み込む
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,年齢\n田中,30\n佐藤,25\n")

      table = CsvCleaner::Reader.new(path).read

      assert_equal %w[氏名 年齢], table.headers
      assert_equal [{ "氏名" => "田中", "年齢" => "30" }, { "氏名" => "佐藤", "年齢" => "25" }], table.rows
      assert_equal 2, table.size
    end
  end

  def test_空のセルは_nil_として読み込む
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,年齢\n田中,\n")

      table = CsvCleaner::Reader.new(path).read

      assert_nil table.rows.first["年齢"]
    end
  end

  def test_列が足りない行は_nil_で補う
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,年齢\n田中\n")

      table = CsvCleaner::Reader.new(path).read

      assert_equal({ "氏名" => "田中", "年齢" => nil }, table.rows.first)
    end
  end

  def test_BOM_付きの_UTF_8_を読み込める
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "﻿氏名,年齢\n田中,30\n")

      table = CsvCleaner::Reader.new(path).read

      assert_equal %w[氏名 年齢], table.headers
    end
  end

  def test_ヘッダーだけのファイルはデータ行が空になる
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,年齢\n")

      table = CsvCleaner::Reader.new(path).read

      assert_empty table.rows
    end
  end

  def test_ファイルが存在しない場合はエラーになる
    error = assert_raises(CsvCleaner::InputError) do
      CsvCleaner::Reader.new("/存在しないディレクトリ/input.csv").read
    end

    assert_includes error.message, "入力ファイルが見つかりません"
  end

  def test_ディレクトリを指定した場合はエラーになる
    in_tmpdir do |dir|
      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(dir).read }

      assert_includes error.message, "ディレクトリ"
    end
  end

  def test_空のファイルはヘッダーがないためエラーになる
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "")

      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(path).read }

      assert_includes error.message, "ヘッダー行が見つかりません"
    end
  end

  def test_同じ名前の列があるとエラーになる
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,氏名\n田中,佐藤\n")

      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(path).read }

      assert_includes error.message, "同じ名前の列"
    end
  end

  def test_ヘッダーより列が多い行はエラーになる
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", "氏名,年齢\n田中,30\n佐藤,25,東京\n")

      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(path).read }

      assert_includes error.message, "3行目"
    end
  end

  def test_引用符が閉じていない_CSV_はエラーになる
    in_tmpdir do |dir|
      path = write_file(dir, "input.csv", %(氏名,備考\n田中,"閉じていない\n))

      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(path).read }

      assert_includes error.message, "CSV の形式が不正です"
    end
  end

  def test_UTF_8_として読めないファイルはエラーになる
    in_tmpdir do |dir|
      path = File.join(dir, "input.csv")
      File.binwrite(path, "氏名,備考\n".encode("Windows-31J") + "田中,メモ\n".encode("Windows-31J"))

      error = assert_raises(CsvCleaner::InputError) { CsvCleaner::Reader.new(path).read }

      assert_includes error.message, "UTF-8"
    end
  end
end
