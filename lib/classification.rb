# frozen_string_literal: true

require 'set'
require 'strscan'

class Classification
  class Error < StandardError; end

  require_relative 'classification/rule_groups'
  require_relative 'classification/global_gitignore'
  require_relative 'classification/gitignore_rule_builder'
  require_relative 'classification/gitignore_include_rule_builder'
  require_relative 'classification/path_regexp_builder'
  require_relative 'classification/gitignore_rule_scanner'
  require_relative 'classification/rule_group'
  require_relative 'classification/matchers/unmatchable'
  require_relative 'classification/matchers/shebang_regexp'
  require_relative 'classification/gitconfig_parser'
  require_relative 'classification/path_expander'
  require_relative 'classification/candidate'
  require_relative 'classification/relative_candidate'
  require_relative 'classification/matchers/within_dir'
  require_relative 'classification/matchers/allow_any_dir'
  require_relative 'classification/matchers/allow_path_regexp'
  require_relative 'classification/matchers/ignore_path_regexp'
  require_relative 'classification/patterns'
  require_relative 'classification/walkers/base'
  require_relative 'classification/walkers/file_system'
  require_relative 'classification/walkers/gitignore_collecting_file_system'
  require_relative 'classification/gitignore_rule_group'
  require_relative 'classification/builders/shebang'
  require_relative 'classification/builders/gitignore'
  require_relative 'classification/builders/shebang_or_gitignore'

  include ::Enumerable

  DOTFILE_NAME = '.unclassified'

  attr_reader :root

  def self.unclassified_files(relative: false, root: nil, **rule_group_builder_args)
    new(relative: relative, root: root, **rule_group_builder_args)
  end

  def initialize(relative: false, root: nil, **rule_group_builder_args)
    @root = "#{::File.expand_path(root.to_s, Dir.pwd)}/"
    @rule_group_builder_args = rule_group_builder_args
    @relative = relative
  end

  def allowed?(path, directory: nil, content: nil, exists: nil, include_directories: false)
    walker.allowed?(
      path,
      root: @root,
      directory: directory,
      content: content,
      exists: exists,
      include_directories: include_directories
    )
  end
  alias_method :===, :allowed?

  def to_proc
    method(:allowed?).to_proc
  end

  def each(&block)
    return enum_for(:each) unless block

    prefix = @relative ? '' : @root

    walker.each(@root, prefix, &block)
  end

  def build
    rule_groups = ::Classification::RuleGroups.new(root: @root, **@rule_group_builder_args)

    @walker = ::Classification::Walkers::GitignoreCollectingFileSystem.new(rule_groups)

    freeze
  end

  private

  def walker
    build unless defined?(@walker)

    @walker
  end
end
