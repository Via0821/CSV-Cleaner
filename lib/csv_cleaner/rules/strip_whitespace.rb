# frozen_string_literal: true

module CsvCleaner
  module Rules
    # 前後の空白を削除し、値の途中にある連続した空白を半角スペース 1 つにまとめる。
    # 全角スペース・タブ・改行も対象。すべての列に適用する。
    class StripWhitespace
      def label
        "空白の整形"
      end

      def applies_to?(_header)
        true
      end

      def call(value)
        return value if value.nil?

        value.gsub(/[[:space:]]+/, " ").strip
      end
    end
  end
end
