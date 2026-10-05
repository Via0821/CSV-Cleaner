# frozen_string_literal: true

module CsvCleaner
  # ヘッダー行とデータ行をまとめて持つ値オブジェクト。
  #
  # headers: 列名の配列 (例: ["氏名", "メールアドレス"])
  # rows:    1 行を { 列名 => 値 } のハッシュで表した配列。値は String か nil。
  Table = Struct.new(:headers, :rows) do
    def size
      rows.size
    end

    # 行だけを差し替えた新しい Table を返す。
    def with_rows(new_rows)
      Table.new(headers, new_rows)
    end
  end
end
