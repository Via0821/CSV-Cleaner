# frozen_string_literal: true

module CsvCleaner
  module Rules
    # 電話番号を区切り記号のない数字列に統一する。
    # 「090-1234-5678」「０９０ １２３４ ５６７８」「+81 90-1234-5678」は
    # いずれも "09012345678" になる。
    #
    # 市外局番の桁数は地域によって異なり、ハイフンの入る位置を正しく決めるには
    # 市外局番表が必要になる。初期版では表記ゆれを確実に吸収することを優先して、
    # 区切り記号を持たない形を正規形とした。
    class NormalizePhone
      HEADER_PATTERN = /phone|tel|mobile|電話|携帯|連絡先/i

      FULLWIDTH = "０-９＋"
      HALFWIDTH = "0-9+"

      JAPAN_COUNTRY_CODE = "81"

      def label
        "電話番号"
      end

      def applies_to?(header)
        header.to_s.match?(HEADER_PATTERN)
      end

      def call(value)
        return value if value.nil?

        normalized = value.tr(FULLWIDTH, HALFWIDTH)
        digits = normalized.gsub(/[^0-9]/, "")
        return nil if digits.empty?
        return digits unless normalized.lstrip.start_with?("+")

        to_domestic_format(digits)
      end

      private

      # 国際表記のうち日本国内の番号は国内表記 (0 始まり) に直す。
      # それ以外の国の番号は + を残して国番号が分かるようにしておく。
      def to_domestic_format(digits)
        if digits.start_with?(JAPAN_COUNTRY_CODE)
          "0#{digits.delete_prefix(JAPAN_COUNTRY_CODE)}"
        else
          "+#{digits}"
        end
      end
    end
  end
end
