# frozen-string-literal: true

class Classification
  module Walkers
    class GitignoreCollectingFileSystem < Base
      def allowed?(path, root: Dir.pwd, directory: nil, content: nil, exists: nil, include_directories: false) # rubocop:disable Metrics/ParameterLists
        full_path = PathExpander.expand_path(path, root)
        return false unless full_path.start_with?(root)

        candidate = ::Classification::Candidate.new(full_path, nil, directory, exists, content)

        begin
          return false if !include_directories && directory?(full_path, directory)
        rescue ::Errno::ENOENT, ::Errno::EACCES, ::Errno::ELOOP, ::Errno::ENAMETOOLONG
          # nil
        end

        return false unless candidate.exists?

        @rule_groups.add_gitignore_to_root(full_path)
        @rule_groups.allowed_recursive?(candidate)
      end

      def each(parent_full_path, parent_relative_path, &block) # rubocop:disable Metrics/MethodLength
        children = ::Dir.children(parent_full_path)
        @rule_groups.add_gitignore(parent_full_path) if children.include?(DOTFILE_NAME)

        children.each do |filename|
          full_path = parent_full_path + filename
          dir = directory?(full_path, nil)
          candidate = ::Classification::Candidate.new(full_path, filename, dir, true, nil)

          next unless @rule_groups.allowed_unrecursive?(candidate)

          relative_path = parent_relative_path + filename

          if dir
            each(full_path + '/', relative_path + '/', &block)
          else
            yield(relative_path)
          end
        rescue ::Errno::ENOENT, ::Errno::EACCES, ::Errno::ENOTDIR, ::Errno::ELOOP, ::Errno::ENAMETOOLONG
          nil
        end
      end
    end
  end
end
