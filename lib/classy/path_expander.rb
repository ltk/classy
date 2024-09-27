# frozen_string_literal: true

module Classy
  module PathExpander
    def self.expand_path(path, dir)
      ::File.expand_path(path, dir)
    rescue ::ArgumentError
      ::File.expand_path("./#{path}", dir)
    end
  end
end
