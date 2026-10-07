# frozen_string_literal: true

# CSV ファイルを読み込み、表記ゆれと重複を整えて書き出すライブラリ。
module CsvCleaner
end

require_relative "csv_cleaner/cli"
require_relative "csv_cleaner/errors"
require_relative "csv_cleaner/processor"
require_relative "csv_cleaner/reader"
require_relative "csv_cleaner/version"
require_relative "csv_cleaner/writer"
