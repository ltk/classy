# frozen_string_literal: true

class Classification
  module Builders
    module Shebang
      def self.build(shebang, allow)
        shebang.strip!
        pattern = /\A#!.*\b#{::Regexp.escape(shebang)}\b/i
        rule = ::Classification::Matchers::ShebangRegexp.new(pattern, allow)
        return rule unless allow

        # also allow all directories in case they include a file with the matching shebang file
        [::Classification::Matchers::AllowAnyDir, rule]
      end
    end
  end
end
