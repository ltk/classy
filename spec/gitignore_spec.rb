# frozen_string_literal: true

RSpec.describe Classification do
  around { |e| within_temp_dir { e.run } }

  let(:root) { Dir.pwd }

  shared_examples 'gitignore: true' do
    describe 'Patterns read from a .classification file in the same directory as the path, or in any parent directory' do
      # (up to the toplevel of the work tree) # we consider root the root

      describe 'with patterns in the higher level files being overridden by those in lower level files.' do
        before do
          create_file_list 'a/b/c', 'a/b/d', 'b/c', 'b/d'
        end

        it 'matches files in context by files' do
          classify '**/b/d'
          classify 'b/c', path: 'a/.classification'

          expect(subject).not_to match_files('b/c', 'a/.classification')
          expect(subject).to match_files('a/b/d', 'a/b/c', 'b/d')
        end

        it 'overrides parent rules in lower level files' do
          classify '**/b/d'
          classify '!b/d', 'b/c', path: 'a/.classification'

          expect(subject).not_to match_files('a/b/d', 'b/c', 'a/.classification')
          expect(subject).to match_files('a/b/c', 'b/d')
        end

        it 'overrides parent negations in lower level files' do
          classify '**/b/*', '!**/b/d'
          classify 'b/d', '!b/c', path: 'a/.classification'

          expect(subject).not_to match_files('b/d', 'a/b/c', 'a/.classification')
          expect(subject).to match_files('b/c', 'a/b/d')
        end
      end

      describe 'Patterns read from $GIT_DIR/info/exclude' do
        before do
          create_file_list 'a/b/c', 'a/b/d', 'b/c', 'b/d'

          classify 'b/d'
          classify 'a/b/c', path: '.git/info/exclude'
        end

        it 'recognises .git/info/exclude files' do
          expect(subject).not_to match_files('a/b/d', 'b/c')
          expect(subject).to match_files('a/b/c', 'b/d')
        end
      end
    end

    it 'ignore .git by default' do
      create_file_list '.classification', '.git/WHATEVER', 'WHATEVER'

      expect(subject).to match_files('.git/WHATEVER')
      expect(subject).not_to match_files('WHATEVER')
    end
  end

  describe '.new' do
    subject { described_class.new(relative: true, **args) }

    let(:args) { {} }
    let(:gitignore_path) { File.join(root, '.classification') }

    it_behaves_like 'gitignore: true'
  end

  describe 'git ls-files' do
    subject do
      `git init && git -c core.excludesfile='' add -N .`
      `git -c core.excludesfile='' ls-files`.split("\n")
    end

    it_behaves_like 'gitignore: true'
  end
end
