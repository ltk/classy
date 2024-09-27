module Classy
  class Node
    attr_reader :parent
    attr_reader :path

    def self.root
      new(path: "#{::File.expand_path(Dir.pwd)}/")
    end

    def initialize(path:, parent: nil)
      @parent = parent
      @path = Pathname.new(path).expand_path
    end

    def files
      return self if file?

      children.map(&:files).flatten
    end

    def unclassified_file_paths
      return path if file? && unclassified?

      children.map(&:unclassified_file_paths).flatten
    end

    def tree
      {
        path.basename => directory? ? children.map(&:tree) : final_eval
      }
    end

    def directory?
      return @directory unless @directory.nil?

      @directory = File.directory?(path)
    end

    def file?
      !directory?
    end

    def unclassified?
      final_eval == :unclassified
    end

    def children
      return [] unless directory?

      ::Dir.children(path).map do |child_path|
        Node.new(parent: self, path: path + child_path)
      end
    end

    def directory_rule_set
      return nil unless directory?
      return @directory_rule_set if @directory_rule_set_checked

      @directory_rule_set_checked = true
      dir_rule = children.find { |child| child.path.basename.to_path == Classy::DOTFILE_NAME }
      return nil unless dir_rule

      @directory_rule_set = RuleSet.new(path: dir_rule.path)
    end

    def rule_sets
      (Array(parent&.rule_sets) + [directory_rule_set]).compact
    end

    def rules
      rule_sets.map(&:rules).flatten.compact
    end

    def final_eval
      return nil if directory?

      rule_evals.final
    end

    def rule_evals
      return nil unless file?

      RuleEvaluationSet.new(node_path: path, rules: rules)
    end
  end
end
