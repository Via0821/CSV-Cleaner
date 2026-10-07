# frozen_string_literal: true

require_relative "test_helper"
require "csv_cleaner/cli"

class CLITest < Minitest::Test
  def setup
    @out = StringIO.new
    @err = StringIO.new
  end

  def test_入力を整形して出力ファイルを作る
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名,電話番号\n 田中 ,090-1234-5678\n")
      output = File.join(dir, "output.csv")

      assert_equal 0, run_cli([input, output])
      assert_equal "氏名,電話番号\n田中,09012345678\n", File.read(output)
    end
  end

  def test_処理結果を標準出力に表示する
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名\n 田中 \n田中\n")

      run_cli([input, File.join(dir, "output.csv")])

      assert_includes @out.string, "クリーニング結果"
      assert_includes @out.string, "重複削除: 1 行"
    end
  end

  def test_quiet_を指定すると処理結果を表示しない
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名\n田中\n")

      assert_equal 0, run_cli(["--quiet", input, File.join(dir, "output.csv")])
      assert_empty @out.string
    end
  end

  def test_引数が足りない場合は使い方を表示する
    assert_equal 2, run_cli(["input.csv"])
    assert_includes @err.string, "2 つを指定してください"
    assert_includes @err.string, "使い方:"
  end

  def test_知らないオプションは使い方を表示する
    assert_equal 2, run_cli(["--unknown", "a.csv", "b.csv"])
    assert_includes @err.string, "使い方:"
  end

  def test_入力と出力に同じパスは指定できない
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名\n田中\n")

      assert_equal 2, run_cli([input, input])
      assert_includes @err.string, "同じパスは指定できません"
      assert_equal "氏名\n田中\n", File.read(input)
    end
  end

  def test_入力ファイルがない場合はエラーを表示する
    in_tmpdir do |dir|
      assert_equal 1, run_cli([File.join(dir, "ない.csv"), File.join(dir, "output.csv")])
      assert_includes @err.string, "入力ファイルが見つかりません"
    end
  end

  def test_出力ファイルが既にある場合はエラーを表示する
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名\n田中\n")
      output = write_file(dir, "output.csv", "既存の内容\n")

      assert_equal 1, run_cli([input, output])
      assert_includes @err.string, "--force"
      assert_equal "既存の内容\n", File.read(output)
    end
  end

  def test_force_を指定すると出力ファイルを上書きする
    in_tmpdir do |dir|
      input = write_file(dir, "input.csv", "氏名\n田中\n")
      output = write_file(dir, "output.csv", "既存の内容\n")

      assert_equal 0, run_cli(["--force", input, output])
      assert_equal "氏名\n田中\n", File.read(output)
    end
  end

  def test_help_で使い方を表示する
    assert_equal 0, run_cli(["--help"])
    assert_includes @out.string, "使い方:"
    assert_includes @out.string, "--force"
  end

  def test_version_でバージョンを表示する
    assert_equal 0, run_cli(["--version"])
    assert_includes @out.string, CsvCleaner::VERSION
  end

  private

  def run_cli(argv)
    CsvCleaner::CLI.run(argv, out: @out, err: @err)
  end
end
