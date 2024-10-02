# frozen_string_literal: true

module Classy
  class Rule
    attr_reader :base_path

    def initialize(base_path:, raw_rule:)
      @base_path = base_path
      @raw_rule = raw_rule
    end

    def evaluate(file_full_path)
      matcher.match?(base_path, file_full_path)
    end

    def specificity
      base_path.to_path.length
    end

    private

    attr_reader :raw_rule

    def matcher
      MatcherBuilder.new(raw_rule, expand_path_with: base_path).build
    end
  end
end
