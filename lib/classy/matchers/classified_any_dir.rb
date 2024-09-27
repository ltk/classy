# frozen_string_literal: true

module Classy
  module Matchers
    module ClassifiedAnyDir
      class << self
        def squash_id
          :classified_any_dir
        end

        def dir_only?
          true
        end

        def file_only?
          false
        end

        def squash(_)
          self
        end

        def weight
          0
        end

        # :nocov:
        def inspect
          '#<AllowAnyDir>'
        end
        # :nocov:

        def match?(_)
          :classified
        end
      end
    end
  end
end
