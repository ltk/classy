# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'classy/version'

Gem::Specification.new do |spec|
  spec.name = 'classy'
  spec.version = Classy::VERSION
  spec.authors = ['Lawson Jaglom-Kurtz']
  spec.email = ['lawson.jaglomkurtz@shopify.com']

  spec.summary = 'Parse .unclassified files to determine file classification in a file tree. '\
    'Inspired by fast_ignore by Dana Sherson<robot@dana.sh>'
  spec.homepage = 'https://github.com/ltk/classy'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.5.0'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  end

  spec.files = Dir.glob('lib/**/*') + Dir.glob('exe/*') + ['CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'leftovers', '>= 0.4.0'
  spec.add_development_dependency 'pry', '> 0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '>= 0.93.1', '< 1.12'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec', '>= 1.44.1'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'spellr', '>= 0.8.3'
end
