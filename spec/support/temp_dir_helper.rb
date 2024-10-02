# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

module TempDirHelper
  module WithinTempDir
    def create_file(*lines, path:)
      path = Pathname.pwd.join(path)
      path.parent.mkpath
      if lines.empty?
        path.write('')
      else
        path.write(lines.join("\n"))
      end
      path
    end

    def create_file_list(*filenames)
      filenames.each do |filename|
        create_file(path: filename)
      end
    end

    def unclassify(*lines, in_dir: nil)
      filepath = if in_dir
        File.join(in_dir, ::Classy::DOTFILE_NAME)
      else
        ::Classy::DOTFILE_NAME
      end
      create_file(*lines, path: filepath)
    end
  end

  def within_temp_dir
    dir = Pathname.new(Dir.mktmpdir)
    original_dir = Dir.pwd
    Dir.chdir(dir)

    extend WithinTempDir
    yield
  ensure
    Dir.chdir(original_dir)
    dir&.rmtree
  end

  def full_path_for(path)
    Pathname.pwd.join(path)
  end
end

RSpec.configure do |config|
  config.include TempDirHelper
end
