# frozen_string_literal: true

module Classy
  module Matchers
    class UnclassifiedPathRegexp
      attr_reader :dir_only
      alias_method :dir_only?, :dir_only
      undef :dir_only

      attr_reader :squash_id
      attr_reader :rule

      def initialize(rule, anchored, dir_only)
        @rule = rule
        @dir_only = dir_only
        @anchored = anchored
        @squash_id = anchored ? :unclassified : object_id

        freeze
      end

      def squash(list)
        self.class.new(::Regexp.union(list.map(&:rule)), @anchored, @dir_only)
      end

      def file_only?
        false
      end

      def weight
        1
      end

      # :nocov:
      def inspect
        "#<UnclassifiedPathRegexp #{'dir_only ' if @dir_only}#{@rule.inspect}>"
      end
      # :nocov:

      def match?(rule_base_path, file_full_path)
        relative_path = file_full_path.relative_path_from(rule_base_path).to_path

        :unclassified if @rule.match?(relative_path)
      end
    end
  end
end
