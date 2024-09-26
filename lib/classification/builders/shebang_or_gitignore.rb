# frozen_string_literal: true

class Classification
  module Builders
    module ShebangOrGitignore
      def self.build(rule, allow, expand_path_with: nil)
        if rule.delete_prefix!('#!:')
          ::Classification::Builders::Shebang.build(rule, allow)
        else
          ::Classification::Builders::Gitignore.build(rule, allow, expand_path_with: expand_path_with)
        end
      end
    end
  end
end
