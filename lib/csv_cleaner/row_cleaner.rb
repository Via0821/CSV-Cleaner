# frozen_string_literal: true

require_relative "rules/normalize_blank"
require_relative "rules/normalize_email"
require_relative "rules/normalize_phone"
require_relative "rules/strip_whitespace"

module CsvCleaner
  # 1 行分のデータに対して、クリーニングルールを順番に適用する。
  #
  # ルールは次の 2 つのメソッドを持つオブジェクトであればよい。
  #   applies_to?(header) ... その列に適用するかどうか
  #   call(value)         ... 整形後の値を返す (nil は欠損値)
  # 新しいルールを足すときは default_rules に 1 行加えるだけで済む。
  class RowCleaner
    # row:            整形後の 1 行 ({ 列名 => 値 })
    # changed_labels: 値が変わったルールのラベル。1 行に複数回入ることもある。
    Result = Struct.new(:row, :changed_labels)

    # 配列の並び順がそのまま適用順になる。
    # 空白を取り除いたうえで欠損値を判定し、その後で列ごとの正規化を行う。
    def self.default_rules
      [
        Rules::StripWhitespace.new,
        Rules::NormalizeBlank.new,
        Rules::NormalizeEmail.new,
        Rules::NormalizePhone.new
      ]
    end

    def initialize(rules = self.class.default_rules)
      @rules = rules
    end

    def clean(row)
      changed_labels = []
      cleaned = row.to_h do |header, value|
        [header, apply_rules(header, value, changed_labels)]
      end

      Result.new(cleaned, changed_labels)
    end

    private

    def apply_rules(header, value, changed_labels)
      @rules.reduce(value) do |current, rule|
        next current unless rule.applies_to?(header)

        updated = rule.call(current)
        changed_labels << rule.label unless updated == current
        updated
      end
    end
  end
end
