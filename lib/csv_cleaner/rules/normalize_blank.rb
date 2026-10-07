# frozen_string_literal: true

module CsvCleaner
  module Rules
    # 空文字や「-」「N/A」といった欠損値のプレースホルダーを nil に統一する。
    # 出力時は空セルになるため、欠損の扱いがファイル全体で揃う。
    class NormalizeBlank
      # 判定は strip + downcase したうえで行う
      PLACEHOLDERS = [
        "",
        "-", "--", "---", "ー", "―", "–", "—",
        "n/a", "n.a.", "null", "nil",
        "なし", "無し", "不明"
      ].freeze

      def label
        "欠損値の統一"
      end

      def applies_to?(_header)
        true
      end

      def call(value)
        return nil if value.nil?

        PLACEHOLDERS.include?(value.strip.downcase) ? nil : value
      end
    end
  end
end
