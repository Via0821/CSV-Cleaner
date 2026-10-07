# frozen_string_literal: true

module CsvCleaner
  # 全列の値が一致する行を重複として検出する。
  #
  # 整形のあとに判定するため、「前後の空白」や「メールアドレスの大文字小文字」
  # だけが違う行も同じ行として扱える。最初に現れた行を残す。
  class DuplicateDetector
    Result = Struct.new(:unique_rows, :duplicate_rows)

    def split(rows)
      seen = {}
      unique_rows = []
      duplicate_rows = []

      rows.each do |row|
        key = key_for(row)
        if seen.key?(key)
          duplicate_rows << row
        else
          seen[key] = true
          unique_rows << row
        end
      end

      Result.new(unique_rows, duplicate_rows)
    end

    private

    # nil と空文字はどちらも欠損値なので、同じキーになるよう to_s で揃える。
    def key_for(row)
      row.values.map(&:to_s)
    end
  end
end
