# frozen-string-literal: true

require 'set'

class Classification
  class GitignoreRuleGroup < ::Classification::RuleGroup
    def initialize(root)
      @root = root
      @loaded_paths = Set[root]

      super([
        ::Classification::Patterns.new(from_file: "#{root}#{Classification::DOTFILE_NAME}", root: root)
      ], true)
    end

    def add_gitignore(dir)
      return if @loaded_paths.include?(dir)

      @loaded_paths << dir
      matcher = ::Classification::Patterns.new(from_file: "#{dir}#{Classification::DOTFILE_NAME}").build_matchers(allow: true)
      @matchers += matcher unless !matcher || matcher.empty?
    end

    def add_gitignore_to_root(path)
      add_gitignore(path) until @loaded_paths.include?(path = "#{::File.dirname(path)}/")
    end
  end
end
