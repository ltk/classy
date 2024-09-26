# frozen-string-literal: true

class Classification
  module Walkers
    class Base
      def initialize(rule_groups)
        @rule_groups = rule_groups
      end

      private

      def directory?(full_path, directory)
        if directory.nil?
          ::File.lstat(full_path).directory?
        else
          directory
        end
      end
    end
  end
end
