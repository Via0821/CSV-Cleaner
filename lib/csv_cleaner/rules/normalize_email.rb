# frozen_string_literal: true

module CsvCleaner
  module Rules
    # メールアドレスを小文字に揃え、全角文字・空白・装飾を取り除く。
    # 列名に「mail」や「メール」を含む列だけに適用する。
    class NormalizeEmail
      HEADER_PATTERN = /mail|メール/i

      # 全角英数記号を半角へ変換するための対応表
      FULLWIDTH = "０-９ａ-ｚＡ-Ｚ＠．＿＋－"
      HALFWIDTH = "0-9a-zA-Z@._+-"

      def label
        "メールアドレス"
      end

      def applies_to?(header)
        header.to_s.match?(HEADER_PATTERN)
      end

      def call(value)
        return value if value.nil?

        normalized = value.tr(FULLWIDTH, HALFWIDTH).gsub(/[[:space:]]/, "").downcase
        normalized = normalized.delete_prefix("mailto:")
        normalized = normalized.delete_prefix("<").delete_suffix(">")
        normalized.empty? ? nil : normalized
      end
    end
  end
end
