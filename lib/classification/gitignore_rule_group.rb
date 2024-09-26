# frozen-string-literal: true

require 'set'

class Classification
  class GitignoreRuleGroup < ::Classification::RuleGroup
    def initialize(root)
      @root = root
      @loaded_paths = Set[root]

      super([
        ::Classification::Patterns.new('.git', root: '/'),
        ::Classification::Patterns.new(from_file: ::Classification::GlobalGitignore.path(root: root), root: root),
        ::Classification::Patterns.new(from_file: "#{root}.git/info/exclude", root: root),
        ::Classification::Patterns.new(from_file: "#{root}#{Classification::DOTFILE_NAME}", root: root)
      ], false)
    end

    def add_gitignore(dir)
      return if @loaded_paths.include?(dir)

      @loaded_paths << dir
      matcher = ::Classification::Patterns.new(from_file: "#{dir}#{Classification::DOTFILE_NAME}").build_matchers(allow: false)
      @matchers += matcher unless !matcher || matcher.empty?
    end

    def add_gitignore_to_root(path)
      add_gitignore(path) until @loaded_paths.include?(path = "#{::File.dirname(path)}/")
    end
  end
end
