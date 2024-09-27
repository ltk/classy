# frozen_string_literal: true

module Classy
  module Matchers
    module Unmatchable
      class << self
        def dir_only?
          false
        end

        def file_only?
          false
        end

        def weight
          0
        end

        # :nocov:
        def inspect
          '#<Unmatchable>'
        end
        # :nocov:

        def match?(_)
          false
        end
      end
    end
  end
end
