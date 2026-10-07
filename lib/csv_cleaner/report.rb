# frozen_string_literal: true

module CsvCleaner
  # 処理結果を集計し、利用者向けのテキストに整える。
  class Report
    # 警告が大量に出たときにターミナルを埋め尽くさないための上限
    MAX_WARNINGS = 10

    attr_accessor :rows_read, :rows_written, :duplicates_removed
    attr_reader :changes, :warnings

    def initialize
      @rows_read = 0
      @rows_written = 0
      @duplicates_removed = 0
      @changes = Hash.new(0)
      @warnings = []
    end

    def record_change(label)
      @changes[label] += 1
    end

    def add_warning(line_number, message)
      @warnings << "#{line_number}行目: #{message}"
    end

    def changed_count
      @changes.values.sum
    end

    def render
      lines = ["クリーニング結果"]
      lines << "  読み込み行数: #{rows_read} 行"
      lines << "  出力行数: #{rows_written} 行"
      lines << "  重複削除: #{duplicates_removed} 行"
      lines << "  変更箇所: #{changed_count} 件"
      lines.concat(change_lines)
      lines.concat(warning_lines)
      lines.join("\n")
    end

    private

    def change_lines
      @changes.map { |label, count| "    #{label}: #{count} 件" }
    end

    def warning_lines
      return [] if @warnings.empty?

      lines = ["  警告: #{@warnings.size} 件"]
      lines.concat(@warnings.first(MAX_WARNINGS).map { |warning| "    #{warning}" })
      remaining = @warnings.size - MAX_WARNINGS
      lines << "    ... ほか #{remaining} 件" if remaining.positive?
      lines
    end
  end
end
