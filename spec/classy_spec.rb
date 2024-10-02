# frozen_string_literal: true

require 'pathname'

RSpec.describe Classy do
  it 'has a version number' do
    expect(Classy::VERSION).not_to be nil
  end

  describe '.ls_unclassified_files' do
    subject { described_class.ls_unclassified_files }

    around { |e| within_temp_dir { e.run } }

    let(:root) { Dir.pwd }

    describe 'simple file unclassification' do
      before do
        create_file_list 'foo', 'bar'
        unclassify 'foo'
      end

      it 'unclassifies the file' do
        expect(subject).to allow_exactly('foo')
      end
    end

    describe 'comments in unclassified file' do
      before do
        create_file_list 'foo', 'bar'
        unclassify '#foo'
      end

      it 'unclassifies the file' do
        expect(subject).to eq([])
      end
    end

    describe 'negated file unclassification' do
      before do
        create_file_list 'foo', 'bar'
        unclassify '*', '!foo'
      end

      it 'keeps the negated file classified' do
        expect(subject).to allow_exactly('bar')
      end
    end

    describe 'subdirectory negated file unclassification' do
      before do
        create_file_list 'lol', 'a/foo', 'a/bar'
        unclassify '*', '!foo', in_dir: 'a'
      end

      it 'keeps the negated file classified' do
        expect(subject).to allow_exactly('a/bar')
      end
    end

    describe 'nested negated file unclassification' do
      before do
        create_file_list 'lol', 'a/foo', 'a/bar'
        unclassify 'a/*'
        unclassify '!foo', in_dir: 'a'
      end

      it 'keeps the negated file classified' do
        expect(subject).to allow_exactly('a/bar')
      end
    end

    describe 'nested negated directory unclassification' do
      before do
        create_file_list 'lol', 'a/foo/hay', 'a/bar/now'
        unclassify 'a/*'
        unclassify '!foo/*', in_dir: 'a'
      end

      it 'keeps the negated file classified' do
        expect(subject).to allow_exactly('a/bar/now')
      end
    end

    describe 'with patterns in the higher level files being overridden by those in lower level files.' do
      before do
        create_file_list 'a/b/c', 'a/b/d', 'b/c', 'b/d'
      end

      it 'matches files in context by files' do
        unclassify '**/b/d'
        unclassify 'b/c', in_dir: 'a'

        expect(subject).to allow_exactly('a/b/c', 'a/b/d', 'b/d')
      end

      it 'overrides parent rules in lower level files' do
        unclassify '**/b/d'
        unclassify '!b/d', 'b/c', in_dir: 'a'

        expect(subject).to allow_exactly('a/b/c', 'b/d')
      end

      it 'overrides parent negations in lower level files' do
        unclassify '**/b/*', '!**/b/d'
        unclassify 'b/d', '!b/c', in_dir: 'a'

        expect(subject).to allow_exactly('a/b/d', 'b/c')
      end
    end

    context 'when passing a from_path' do
      subject { described_class.ls_unclassified_files(from_path: 'a') }

      before do
        create_file_list 'a/b/c', 'a/b/d', 'b/c', 'b/d'
      end

      describe 'simple file unclassification' do
        before do
          create_file_list 'a/foo', 'a/bar', 'b/foo', 'b/bar'
          unclassify 'a/foo'
        end

        it 'unclassifies the file' do
          expect(subject).to allow_exactly('a/foo')
        end
      end
    end
  end

  describe '.classification_of' do
    around { |e| within_temp_dir { e.run } }

    before do
      create_file_list 'foo', 'bar'
      unclassify 'foo'
    end

    context 'when providing a path to a classified file' do
      subject { described_class.classification_of('bar') }

      it 'returns CLASSIFIED' do
        expect(subject).to eq('CLASSIFIED')
      end
    end

    context 'when providing a path to an unclassified file' do
      subject { described_class.classification_of('foo') }

      it 'returns UNCLASSIFIED' do
        expect(subject).to eq('UNCLASSIFIED')
      end
    end

    context 'when providing a path to a non-existent file' do
      subject { described_class.classification_of('non-existent') }

      it 'returns an error message' do
        expect(subject).to include('non-existent` is not a file')
      end
    end
  end

  describe '.cli' do
    subject { described_class.cli(args) }

    around { |e| within_temp_dir { e.run } }

    before do
      create_file_list 'foo', 'bar', 'baz', 'qux'
      unclassify 'foo', 'baz'
    end

    context 'when no arguments are provided' do
      let(:args) { [] }

      it 'returns the usage message' do
        expect(subject).to include('Usage: cls <command> [args]')
      end
    end

    context 'when calling with "ls"' do
      let(:args) { ['ls'] }

      it 'returns the unclassified file list' do
        expect(subject).to eq([full_path_for('foo'), full_path_for('baz')].join("\n"))
      end
    end

    context 'when calling with "test"' do
      let(:args) { ['test', 'foo'] }

      it 'returns the classification of the file' do
        expect(subject).to eq('UNCLASSIFIED')
      end
    end
  end
end
