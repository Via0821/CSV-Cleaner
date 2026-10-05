# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "minitest/autorun"
require "stringio"
require "tmpdir"

module TestHelpers
  # 一時ディレクトリを用意してブロックに渡す。終了時に自動で削除される。
  def in_tmpdir(&block)
    Dir.mktmpdir("csv-cleaner-test", &block)
  end

  def write_file(dir, name, content)
    path = File.join(dir, name)
    File.write(path, content)
    path
  end
end

Minitest::Test.include(TestHelpers)
