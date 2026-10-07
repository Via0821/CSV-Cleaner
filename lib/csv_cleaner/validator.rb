# frozen_string_literal: true

require_relative "rules/normalize_email"
require_relative "rules/normalize_phone"

module CsvCleaner
  # 整形後の値が想定した形式になっているかを確認する。
  #
  # 不正な値でも行は削除しない。機械的に直せない内容は人が判断すべきなので、
  # 警告として報告し、データはそのまま出力する。
  class Validator
    EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

    # 国内番号は 0 始まりの 10 桁または 11 桁
    DOMESTIC_PHONE_FORMAT = /\A0\d{9,10}\z/

    # 国際番号は + のあとに 8〜15 桁 (E.164)
    INTERNATIONAL_PHONE_FORMAT = /\A\+\d{8,15}\z/

    # 警告メッセージの配列を返す。問題がなければ空配列。
    def validate(row)
      row.filter_map { |header, value| warning_for(header, value) }
    end

    private

    def warning_for(header, value)
      return nil if value.nil?

      if email_column?(header)
        invalid_message(header, value) unless EMAIL_FORMAT.match?(value)
      elsif phone_column?(header)
        invalid_message(header, value) unless valid_phone?(value)
      end
    end

    def email_column?(header)
      Rules::NormalizeEmail::HEADER_PATTERN.match?(header.to_s)
    end

    def phone_column?(header)
      Rules::NormalizePhone::HEADER_PATTERN.match?(header.to_s)
    end

    def valid_phone?(value)
      DOMESTIC_PHONE_FORMAT.match?(value) || INTERNATIONAL_PHONE_FORMAT.match?(value)
    end

    def invalid_message(header, value)
      "「#{header}」の形式が正しくありません (#{value})"
    end
  end
end
