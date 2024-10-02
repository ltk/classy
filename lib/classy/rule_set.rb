# frozen_string_literal: true

module Classy
  class RuleSet
    def initialize(path:)
      @path = Pathname.new(path).expand_path
    end

    def rules
      @rules ||= lines.map do |line|
        stripped_line = line.strip
        next if stripped_line.empty? || stripped_line.start_with?('#')

        Rule.new(base_path: path.dirname, raw_rule: stripped_line)
      end
    end

    private

    attr_reader :path

    def lines
      File.readlines(path)
    end
  end
end
