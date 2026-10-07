# frozen_string_literal: true

require "optparse"

require_relative "errors"
require_relative "processor"
require_relative "reader"
require_relative "version"
require_relative "writer"

module CsvCleaner
  # コマンドラインから呼び出される入口。
  # 引数の解釈とエラーメッセージの表示を担当し、処理そのものは Processor に任せる。
  class CLI
    EXIT_SUCCESS = 0
    EXIT_ERROR = 1
    EXIT_USAGE = 2

    BANNER = <<~TEXT
      使い方: csv-cleaner [オプション] <入力ファイル> <出力ファイル>

      CSV を読み込み、表記ゆれと重複を整えた CSV を書き出します。

      例:
        csv-cleaner examples/messy_contacts.csv cleaned.csv
    TEXT

    # 終了ステータスを返す。テストから出力先を差し替えられるようにしている。
    def self.run(argv, out: $stdout, err: $stderr)
      new(out: out, err: err).run(argv)
    end

    def initialize(out: $stdout, err: $stderr)
      @out = out
      @err = err
      @options = { force: false, quiet: false, help: false, version: false }
    end

    def run(argv)
      arguments = parser.parse(argv)
      return print_help if @options[:help]
      return print_version if @options[:version]

      clean(*validate(arguments))
      EXIT_SUCCESS
    rescue OptionParser::ParseError, UsageError => e
      report_usage_error(e.message)
    rescue Error => e
      @err.puts "エラー: #{e.message}"
      EXIT_ERROR
    end

    private

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = BANNER
        opts.separator ""
        opts.separator "オプション:"
        opts.on("-f", "--force", "出力ファイルが既にあっても上書きする") { @options[:force] = true }
        opts.on("-q", "--quiet", "処理結果の表示を省略する") { @options[:quiet] = true }
        opts.on("-h", "--help", "このヘルプを表示する") { @options[:help] = true }
        opts.on("-v", "--version", "バージョンを表示する") { @options[:version] = true }
      end
    end

    def validate(arguments)
      unless arguments.size == 2
        raise UsageError, "入力ファイルと出力ファイルの 2 つを指定してください"
      end

      input, output = arguments
      if File.expand_path(input) == File.expand_path(output)
        raise UsageError, "入力ファイルと出力ファイルに同じパスは指定できません"
      end

      [input, output]
    end

    def clean(input, output)
      result = Processor.new.process(Reader.new(input).read)
      Writer.new(output, force: @options[:force]).write(result.table)
      @out.puts result.report.render unless @options[:quiet]
    end

    def print_help
      @out.puts parser.help
      EXIT_SUCCESS
    end

    def print_version
      @out.puts "csv-cleaner #{VERSION}"
      EXIT_SUCCESS
    end

    def report_usage_error(message)
      @err.puts "エラー: #{message}"
      @err.puts
      @err.puts parser.help
      EXIT_USAGE
    end
  end
end
