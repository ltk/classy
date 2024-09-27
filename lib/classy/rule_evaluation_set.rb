module Classy
  class RuleEvaluationSet
    EVAL_PRECEDENCE = [
      :classified,
      :unclassified
    ].freeze

    Eval = Struct.new(:evaluation, :specificity, :precedence)

    def initialize(node_path:, rules:)
      @node_path = node_path
      @rules = rules
      @highest_priority = nil
    end

    def final
      # Never unclassify the classification file itself, this can expose sensitive filenames
      return :classified if node_path.basename.to_path == Classy::DOTFILE_NAME

      all.min_by { |e| [-e.specificity, e.precedence] }&.evaluation
    end

    def all
      rules.map do |rule|
        evaluation = rule.evaluate(node_path)
        next unless evaluation

        # self.max_specificity = rule.specificity if max_specificity.nil? || rule.specificity < max_specificity
        Eval.new(evaluation, rule.specificity, EVAL_PRECEDENCE.index(evaluation))
      end.compact
    end

    private

    attr_accessor :max_specificity
    attr_reader :node_path
    attr_reader :rules
  end
end
