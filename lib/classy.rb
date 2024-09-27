require 'pathname'
require 'pry'

require_relative 'classy/node'
require_relative 'classy/rule'
require_relative 'classy/rule_set'
require_relative 'classy/rule_evaluation_set'
require_relative 'classy/match_scanner'
require_relative 'classy/matcher_builder'
require_relative 'classy/path_expander'
require_relative 'classy/path_regexp_builder'
require_relative 'classy/matchers/within_dir'
require_relative 'classy/matchers/classified_any_dir'
require_relative 'classy/matchers/classified_path_regexp'
require_relative 'classy/matchers/unclassified_path_regexp'

module Classy
  class Error < StandardError; end

  DOTFILE_NAME = '.unclassified'.freeze

  def self.ls_unclassified_files(from_path: nil)
    root = if from_path
      Node.new(path: "#{::File.expand_path(from_path, Dir.pwd)}/")
    else
      Node.root
    end

    root.unclassified_file_paths.map(&:to_path)
  end

  def self.classification_of(file_path)
    full_file_path = Pathname.new(file_path).expand_path

    return "Error: `#{full_file_path.to_path}` is not a file" unless File.file?(full_file_path)

    ls_unclassified_files.include?(full_file_path.to_path) ? 'UNCLASSIFIED' : 'CLASSIFIED'
  end

  def self.root
    Node.root
  end

  def self.cli(args)
    first_arg = args.first.strip
    case first_arg
    when 'ls'
      puts ls_unclassified_files
    when 'test'
      file_path = args[1]&.strip
      if file_path.nil? || file_path == ''
        puts 'Usage: cls test <file_path>'
        return
      end

      puts classification_of(file_path)
    else
      puts 'Usage: cls <command> [args]'
      puts 'Commands:'
      puts '  ls - List unclassified files'
      puts '  test <file_path> - Show the classification status of a given file'
    end
  end
end
