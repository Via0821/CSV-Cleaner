# frozen_string_literal: true

require_relative "duplicate_detector"
require_relative "report"
require_relative "row_cleaner"
require_relative "validator"

module CsvCleaner
  # 読み込んだ表に対して「整形 → 検証 → 重複除去」を順番に適用する。
  # ファイルの読み書きは担当せず、Table を受け取って Table を返す。
  class Processor
    Result = Struct.new(:table, :report)

    # 1 行目はヘッダーなので、データ 1 行目はファイルの 2 行目にあたる
    FIRST_DATA_LINE = 2

    def initialize(cleaner: RowCleaner.new, validator: Validator.new, detector: DuplicateDetector.new)
      @cleaner = cleaner
      @validator = validator
      @detector = detector
    end

    def process(table)
      report = Report.new
      report.rows_read = table.size

      cleaned_rows = table.rows.each_with_index.map do |row, index|
        clean_row(row, index + FIRST_DATA_LINE, report)
      end

      deduplicated = @detector.split(cleaned_rows)
      report.duplicates_removed = deduplicated.duplicate_rows.size
      report.rows_written = deduplicated.unique_rows.size

      Result.new(table.with_rows(deduplicated.unique_rows), report)
    end

    private

    def clean_row(row, line_number, report)
      result = @cleaner.clean(row)
      result.changed_labels.each { |label| report.record_change(label) }
      @validator.validate(result.row).each { |message| report.add_warning(line_number, message) }
      result.row
    end
  end
end
