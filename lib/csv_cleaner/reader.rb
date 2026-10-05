# frozen_string_literal: true

require "csv"

require_relative "errors"
require_relative "table"

module CsvCleaner
  # CSV ファイルを読み込んで Table に変換する。
  # ヘッダー行があることを前提とし、構造上の問題は InputError として報告する。
  class Reader
    # BOM 付き UTF-8 もそのまま扱えるようにしている
    ENCODING = "bom|utf-8"

    # ヘッダー行のぶんだけずらして、エラーメッセージの行番号を実ファイルに合わせる
    FIRST_DATA_LINE = 2

    def initialize(path)
      @path = path
    end

    def read
      ensure_readable
      csv = parse
      Table.new(read_headers(csv), read_rows(csv))
    end

    private

    def ensure_readable
      raise InputError, "入力ファイルが見つかりません: #{@path}" unless File.exist?(@path)
      raise InputError, "入力ファイルにディレクトリは指定できません: #{@path}" if File.directory?(@path)
      raise InputError, "入力ファイルを読み取る権限がありません: #{@path}" unless File.readable?(@path)
    end

    def parse
      CSV.read(@path, headers: true, encoding: ENCODING)
    rescue CSV::InvalidEncodingError, ArgumentError
      # Shift_JIS などの CSV を渡された場合。先に文字コードを変換してもらう。
      raise InputError, "UTF-8 として読み込めません: #{@path}"
    rescue CSV::MalformedCSVError => e
      raise InputError, "CSV の形式が不正です (#{@path}): #{e.message}"
    end

    def read_headers(csv)
      headers = Array(csv.headers).map(&:to_s)
      raise InputError, "ヘッダー行が見つかりません: #{@path}" if headers.empty?

      duplicated = headers.tally.select { |_header, count| count > 1 }.keys
      unless duplicated.empty?
        raise InputError, "同じ名前の列が複数あります: #{duplicated.join(", ")}"
      end

      headers
    end

    def read_rows(csv)
      csv.each_with_index.map do |row, index|
        # ヘッダーより列が多い行は nil キーになる。区切り文字の
        # エスケープ漏れが原因であることが多いため、黙って捨てずに知らせる。
        if row.headers.include?(nil)
          raise InputError, "#{index + FIRST_DATA_LINE}行目の列数がヘッダーより多くなっています: #{@path}"
        end

        row.to_h
      end
    end
  end
end
