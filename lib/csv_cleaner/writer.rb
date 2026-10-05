# frozen_string_literal: true

require "csv"

require_relative "errors"

module CsvCleaner
  # Table を CSV ファイルとして書き出す。
  # 既存ファイルは force: true を指定しない限り上書きしない。
  class Writer
    def initialize(path, force: false)
      @path = path
      @force = force
    end

    def write(table)
      ensure_writable
      CSV.open(@path, "w", write_headers: true, headers: table.headers) do |csv|
        table.rows.each { |row| csv << table.headers.map { |header| row[header] } }
      end
      @path
    rescue SystemCallError => e
      raise OutputError, "出力ファイルに書き込めません (#{@path}): #{e.message}"
    end

    private

    def ensure_writable
      if File.exist?(@path) && !@force
        raise OutputError, "出力ファイルが既に存在します (上書きするには --force): #{@path}"
      end
      raise OutputError, "出力先にディレクトリは指定できません: #{@path}" if File.directory?(@path)

      directory = File.dirname(@path)
      raise OutputError, "出力先のディレクトリがありません: #{directory}" unless File.directory?(directory)
    end
  end
end
