# frozen_string_literal: true

require 'pathname'

require_relative 'classy/node'
require_relative 'classy/rule'
require_relative 'classy/rule_set'
require_relative 'classy/rule_evaluation_set'
require_relative 'classy/match_scanner'
require_relative 'classy/matcher_builder'
require_relative 'classy/path_expander'
require_relative 'classy/path_regexp_builder'
require_relative 'classy/matchers/classified_path_regexp'
require_relative 'classy/matchers/unclassified_path_regexp'

module Classy
  class Error < StandardError; end

  DOTFILE_NAME = '.unclassified'

  def self.ls_unclassified_files(from_path: nil)
    files = root.unclassified_file_paths.map(&:to_path)

    return files unless from_path

    filter_path = ::File.expand_path(from_path, Dir.pwd)
    files.select { |file| file.start_with?(filter_path) }
  end

  def self.classification_of(file_path)
    full_file_path = Pathname.new(file_path).expand_path

    return "Error: `#{full_file_path.to_path}` is not a file" unless File.file?(full_file_path)

    ls_unclassified_files.include?(full_file_path.to_path) ? 'UNCLASSIFIED' : 'CLASSIFIED'
  end

  def self.cli(args) # rubocop:disable Metrics/MethodLength
    first_arg = args.first&.strip
    case first_arg
    when 'ls'
      ls_unclassified_files.join("\n")
    when 'test'
      file_path = args[1]&.strip
      if file_path.nil? || file_path == ''
        puts 'Usage: cls test <file_path>'
        return
      end

      classification_of(file_path)
    else
      <<~MSG
        Usage: cls <command> [args]
        Commands:
          ls - List unclassified files
          test <file_path> - Show the classification status of a given file
      MSG
    end
  end

  def self.root
    Node.root
  end
end
