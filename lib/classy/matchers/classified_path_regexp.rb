# frozen_string_literal: true

module Classy
  module Matchers
    class ClassifiedPathRegexp
      attr_reader :dir_only
      alias_method :dir_only?, :dir_only
      undef :dir_only

      attr_reader :squash_id
      attr_reader :rule

      def initialize(rule, squashable, dir_only)
        @rule = rule
        @dir_only = dir_only
        @squashable = squashable
        @squash_id = squashable ? :classified : object_id

        freeze
      end

      def squash(list)
        self.class.new(::Regexp.union(list.map(&:rule)), @squashable, @dir_only)
      end

      def file_only?
        false
      end

      def weight
        1
      end

      # :nocov:
      def inspect
        "#<ClassifiedPathRegexp #{'dir_only ' if @dir_only}#{@rule.inspect}>"
      end
      # :nocov:

      def match?(rule_base_path, file_full_path)
        relative_path = file_full_path.relative_path_from(rule_base_path).to_path
        :classified if @rule.match?(relative_path)
      end
    end
  end
end
