# Classification

[![travis](https://travis-ci.com/robotdana/fast_ignore.svg?branch=main)](https://travis-ci.com/robotdana/fast_ignore)
[![Gem Version](https://badge.fury.io/rb/fast_ignore.svg)](https://rubygems.org/gems/fast_ignore)

This started as a way to quickly and natively ruby-ly parse gitignore files and find matching files.
It's now gained an equivalent includes file functionality, ARGV awareness, and some shebang matching, while still being extremely fast, to be a one-stop file-list for your linter.

Filter a directory tree using a .gitignore file. Recognises all of the [gitignore rules](https://www.git-scm.com/docs/gitignore#_pattern_format)

```ruby
Classification.new(relative: true).sort == `git ls-files`.split("\n").sort
```

## Features

- Fast (faster than using `` `git ls-files`.split("\n") `` for small repos (because it avoids the overhead of ` `` `))
- Supports ruby 2.5-3.1.x & jruby
- supports all [gitignore rule patterns](https://git-scm.com/docs/gitignore#_pattern_format)
- doesn't require git to be installed
- supports a gitignore-esque "include" patterns. ([`include_rules:`](#include_rules)/[`include_files:`](#include_files))
- supports an expansion of include patterns, expanding and anchoring paths ([`argv_rules:`](#argv_rules))
- supports [matching by shebang](#shebang_rules) rather than filename for extensionless files: `#!:`
- reads .gitignore in all subdirectories
- reads .git/info/excludes
- reads the global gitignore file mentioned in your git config

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_ignore'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install fast_ignore
```

## Usage

```ruby
Classification.new.each { |file| puts "#{file} is not ignored by the .gitignore file" }
```

### `#each`, `#map` etc

This yields paths that are _not_ ignored by the gitignore, i.e. the paths that would be returned by `git ls-files`.

A Classification instance is an Enumerable and responds to all Enumerable methods:

```ruby
Classification.new.to_a
Classification.new.map { |file| file.upcase }
```

Like other enumerables, `Classification#each` can return an enumerator:

```ruby
Classification.new.each.with_index { |file, index| puts "#{file}#{index}" }
```

**Warning: Do not change directory (e.g. `Dir.chdir`) in the block.**

### `#allowed?`

To check if a single path is allowed, use

```ruby
Classification.new.allowed?('relative/path')
Classification.new.allowed?('./relative/path')
Classification.new.allowed?('/absolute/path')
Classification.new.allowed?('~/home/path')
```

Relative paths will be considered relative to the [`root:`](#root) directory, not the current directory.

This is aliased as `===` so you can use a Classification instance in case statements.

```ruby
@path_matcher ||= Classification.new

case my_path
when @path_matcher
  puts(my_path)
end
```

It's recommended to save the Classification instance to a variable to avoid having to read and parse the gitignore file and gitconfig files repeatedly.

#### directory: true/false/nil

If your code already knows the path to test is/not a directory or wants to lie about whether it is/is not a directory, you can pass `directory: true` or `directory: false` as an argument to `allowed?` (to have Classification ask the file system, you can pass `directory: nil` or nothing)

```
Classification.new.allowed?('relative/path', directory: false) # matches `path` as a file
Classification.new.allowed?('relative/path', directory: true) # matches `path` as a directory
Classification.new.allowed?('relative/path', directory: nil) # matches path as whatever it is on the filesystem
Classification.new.allowed?('relative/path)                  # or as a file if it doesn't exist on the file system
```

#### content: true/false/nil

default: `nil`

If your code already knows the path to test is has a particular text content or wants to lie about the content, you can pass `directory: true` or `directory: false` as an argument to `allowed?` (to have Classification ask the file system, you can pass `directory: nil` or nothing)

```
Classification.new.allowed?('relative/path', content: "#!/usr/bin/env ruby\n\nputs 'hello'") # matches ruby shebang
Classification.new.allowed?('relative/path', content: "#!/usr/bin/env bash\n\necho 'hello'") # matches bash shebang
Classification.new.allowed?('relative/path', content: nil) # matches path as whatever content is on the filesystem
Classification.new.allowed?('relative/path)                # or as an empty file if it doesn't actually exist
```

#### content: true/false/nil

default: `nil`

If your code already knows the path to test is has a particular text content or wants to lie about the content, you can pass `directory: true` or `directory: false` as an argument to `allowed?` (to have Classification ask the file system, you can pass `directory: nil` or nothing)

```
Classification.new.allowed?('relative/path', content: "#!/usr/bin/env ruby\n\nputs 'hello'") # matches ruby shebang
Classification.new.allowed?('relative/path', content: "#!/usr/bin/env bash\n\necho 'hello'") # matches bash shebang
Classification.new.allowed?('relative/path', content: nil) # matches path as whatever content is on the filesystem
Classification.new.allowed?('relative/path)                # or as an empty file if it doesn't actually exist
```

#### exist: true/false/nil

default: `nil`

If your code already knows the path to test exists or wants to lie about its existence, you can pass `exists: true` or `exists: false` as an argument to `allowed?` (to have Classification ask the file system, you can pass `exists: nil` or nothing)

```
Classification.new.allowed?('relative/path', exists: true) # will check the path regardless of whether it actually truly exists
Classification.new.allowed?('relative/path', exists: false) # will always return false
Classification.new.allowed?('relative/path', exists: nil) # asks the filesystem
Classification.new.allowed?('relative/path)               # asks the filesystem
```

#### include_directories: true/false

default: `false`

By default a file must not be a directory for it to be considered allowed. This is intended to match the behaviour of `git ls-files` which only lists files.

To match directories you can pass `include_directories: true` to `allowed?`

```
Classification.new.allowed?('relative/path', include_directories: true) # will test the path even if it's a directory
Classification.new.allowed?('relative/path', include_directories: false) # will always return false if the path is a directory
Classification.new.allowed?('relative/path)                        # will always return false if the path is a directory
```

### `relative: true`

**Default: false**

When `relative: false`: Classification#each will yield full paths.
When `relative: true`: Classification#each will yield paths relative to the [`root:`](#root) directory

```ruby
Classification.new(relative: true).to_a
```

### `root:`

**Default: Dir.pwd ($PWD, the current working directory)**

This directory is used for:

- the location of `.git/core/exclude`
- the ancestor of all non-global [automatically loaded `.gitignore` files](#gitignore_false)
- the root directory for array rules ([`ignore_rules:`](#ignore_rules), [`include_rules:`](#include_rules), [`argv_rules:`](#argv_rules)) containing `/`
- the path that [`relative:`](#relative_true) is relative to
- the ancestor of all paths yielded by [`#each`](#each_map_etc)
- the path that [`#allowed?`](#allowed) considers relative paths relative to
- the ancestor of all [`include_files:`](#include_files) and [`ignore_files:`](#ignore_files)

To use a different directory:

```ruby
Classification.new(root: '/absolute/path/to/root').to_a
Classification.new(root: '../relative/path/to/root').to_a
```

A relative root will be found relative to the current working directory when the Classification instance is initialized, and that will be the last time the current working directory is relevant.

**Note: Changes to the current working directory (e.g. with `Dir.chdir`), after initialising a Classification instance, will _not_ affect the Classification instance. `root:` will always be what it was when the instance was initialized, even as a default value.**

### `gitignore:`

**Default: true**

When `gitignore: true`: the .gitignore file in the [`root:`](#root) directory is loaded, plus any .gitignore files in its subdirectories, the global git ignore file as described in git config, and .git/info/exclude. `.git` directories are also excluded to match the behaviour of `git ls-files`.
When `gitignore: false`: no ignore files or git config files are automatically read, and `.git` will not be automatically excluded.

```ruby
Classification.new(gitignore: false).to_a
```

### `ignore_files:`

**This is a list of files in the gitignore format to parse and match paths against, not a list of files to ignore** If you want an array of files use [`ignore_rules:`](#ignore_rules)

Additional gitignore-style files, either as a path or an array of paths.

You can specify other gitignore-style files to ignore as well.
Missing files will raise an `Errno::ENOENT` error.

Relative paths are relative to the [`root:`](#root) directory.
Absolute paths also need to be within the [`root:`](#root) directory.

```ruby
Classification.new(ignore_files: 'relative/path/to/my/ignore/file').to_a
Classification.new(ignore_files: ['/absolute/path/to/my/ignore/file', '/and/another']).to_a
```

Note: the location of the files will affect rules beginning with or containing `/`.

To avoid raising `Errno::ENOENT` when the file doesn't exist:

```ruby
Classification.new(ignore_files: ['/ignore/file'].select { |f| File.exist?(f) }).to_a
```

### `ignore_rules:`

This can be a string, or an array of strings, and multiline strings can be used with one rule per line.

```ruby
Classification.new(ignore_rules: '.DS_Store').to_a
Classification.new(ignore_rules: ['.git', '.gitkeep']).to_a
Classification.new(ignore_rules: ".git\n.gitkeep").to_a
```

These rules use the [`root:`](#root) argument to resolve rules containing `/`.

### `include_files:`

**This is an array of files in the gitignore format to parse and match paths against, not a list of files to include.** If you want an array of files use [`include_rules:`](#include_rules).

Building on the gitignore format, Classification also accepts rules to include matching paths (rather than ignoring them).
A rule matching a directory will include all descendants of that directory.

These rules can be provided in files either as absolute or relative paths, or an array of paths.
Relative paths are relative to the [`root:`](#root) directory.
Absolute paths also need to be within the [`root:`](#root) directory.

```ruby
Classification.new(include_files: 'my_include_file').to_a
Classification.new(include_files: ['/absolute/include/file', './relative/include/file']).to_a
```

Missing files will raise an `Errno::ENOENT` error.

To avoid raising `Errno::ENOENT` when the file doesn't exist:

```ruby
Classification.new(include_files: ['include/file'].select { |f| File.exist?(f) }).to_a
```

**Note: All paths checked must not be excluded by any ignore files AND each included by include file separately AND the [`include_rules:`](#include_rules) AND the [`argv_rules:`](#argv_rules). see [Combinations](#combinations) for solutions to using OR.**

### `include_rules:`

Building on the gitignore format, Classification also accepts rules to include matching paths (rather than ignoring them).
A rule matching a directory will include all descendants of that directory.

This can be a string, or an array of strings, and multiline strings can be used with one rule per line.

```ruby
Classification.new(include_rules: %w{my*rule /and/another !rule}, gitignore: false).to_a
```

Rules use the [`root:`](#root) argument to resolve rules containing `/`.

**Note: All paths checked must not be excluded by any ignore files AND each included by [include file](#include_files) separately AND the `include_rules:` AND the [`argv_rules:`](#argv_rules). see [Combinations](#combinations) for solutions to using OR.**

### `argv_rules:`

This is like [`include_rules:`](#include_rules) with additional features meant for dealing with humans and `ARGV` values.

It expands rules that are absolute paths, and paths beginning with `~`, `../` and `./` (with and without `!`).
This means rules beginning with `/` are absolute. Not relative to [`root:`](#root).

Additionally it assumes all rules are relative to the [`root:`](#root) directory (after resolving absolute paths) unless they begin with `*` (or `!*`).

This can be a string, or an array of strings, and multiline strings can be used with one rule per line.

```ruby
Classification.new(argv_rules: ['./a/pasted/path', '/or/a/path/from/stdin', 'an/argument', '*.txt']).to_a
```

**Warning: it will _not_ expand e.g. `/../` in the middle of a rule that doesn't begin with any of `~`,`../`,`./`,`/`.**

**Note: All paths checked must not be excluded by any ignore files AND each included by [include file](#include_files) separately AND the [`include_rules:`](#include_rules) AND the `argv_rules:`. see [Combinations](#combinations) for solutions to using OR.**

### shebang rules

Sometimes you need to match files by their shebang/hashbang/etc rather than their path or filename

Rules beginning with `#!:` will match whole words in the shebang line of extensionless files.
e.g.

```gitignore
#!:ruby
```

will match shebang lines: `#!/usr/bin/env ruby` or `#!/usr/bin/ruby` or `#!/usr/bin/ruby -w`

e.g.

```gitignore
#!:bin/ruby
```

will match `#!/bin/ruby` or `#!/usr/bin/ruby` or `#!/usr/bin/ruby -w`
Only exact substring matches are available, There's no special handling of \* or / or etc.

These rules can be supplied any way regular rules are, whether in a .gitignore file or files mentioned in [`include_files:`](#include_files) or [`ignore_files:`](#ignore_files) or [`include_rules:`](#include_rules) or [`ignore_rules:`](#ignore_rules) or [`argv_rules:`](#argv_rules)

```ruby
Classification.new(include_rules: ['*.rb', '#!:ruby']).to_a
Classification.new(ignore_rules: ['*.sh', '#!:sh', '#!:bash', '#!:zsh']).to_a
```

**Note: git considers rules like this as a comment and will ignore them.**

## Combinations

In the simplest case a file must be allowed by each ignore file, each include file, and each array of rules. That is, they are combined using `AND`.

To combine files using `OR`, that is, a file may be matched by either file it doesn't have to be referred to in both:
provide the files as strings to [`include_rules:`](#include_rules) or [`ignore_rules:`](#ignore_rules)

```ruby
Classification.new(include_rules: [File.read('/my/path'), File.read('/another/path')])).to_a
```

This does unfortunately lose the file path as the root for rules containing `/`.
If that's important, combine the files in the file system and use [`include_files:`](#include_files) or [`ignore_files:`](#ignore_files) as normal.

To use the additional `ARGV` handling of [`argv_rules:`](#argv_rules) on a file, read the file into the array.

```ruby
Classification.new(argv_rules: ["my/rule", File.read('/my/path')]).to_a
```

This does unfortunately lose the file path as the root `/` and there is no workaround except setting the [`root:`](#root) for the whole Classification instance.

## Limitations

- Doesn't know what to do if you change the current working directory inside the [`Classification#each`](#each_map_etc) block.
  So don't do that.

  (It does handle changing the current working directory between [`Classification#allowed?`](#allowed) calls)

- Classification always matches patterns case-insensitively. (git varies by filesystem).
- Classification always outputs paths as literal UTF-8 characters. (git depends on your core.quotepath setting but by default outputs non ascii paths with octal escapes surrounded by quotes).
- git has a system-wide config file installed at `$(prefix)/etc/gitconfig`, where `prefix` is defined for git at install time. Classification assumes that it will always be `/usr/local/etc/gitconfig`. if it's important your system config file is looked at, as that's where you have the core.excludesfile defined, use git's built-in way to override this by adding `export GIT_CONFIG_SYSTEM='/the/actual/location'` to your shell profile.
- Because git looks at its own index objects and Classification looks at the file system there may be some differences between Classification and `git ls-files`. To avoid these differences you may want to use the [`git_ls`](https://github.com/robotdana/git_ls) gem instead
  - Tracked files that were committed before the matching ignore rule was committed will be returned by `git ls-files`, but not by Classification.
  - Untracked files will be returned by Classification, but not by `git ls-files`
  - Deleted files whose deletions haven't been committed will be returned by `git ls-files`, but not by Classification
  - On a case insensitive file system, with files that differ only by case, `git ls-files` will include all case variations, while Classification will only include whichever variation git placed in the file system.
  - Classification is unaware of submodules and just treats them like regular directories. For example: `git ls-files --recurse-submodules` won't use the parent repo's gitignore on a submodule, while Classification doesn't know it's a submodule and will.
  - Classification will only return the files actually on the file system when using `git sparse-checkout`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/fast_ignore.

Some tools that may help:

- `bin/setup`: install development dependencies
- `bundle exec rspec`: run all tests
- `bundle exec rake`: run all tests and linters
- `bin/console`: open a `pry` console with everything required for experimenting
- `bin/ls [argv_rules]`: the equivalent of `git ls-files`
- `bin/prof/ls [argv_rules]`: ruby-prof report for `bin/ls`
- `bin/prof/parse [argv_rules]`: ruby-prof report for parsing root and global gitignore files and any arguments.
- `bin/time [argv_rules]`: the average time for 30 runs of `bin/ls`<br>
  This repo is too small to stress bin/time more than 0.01s, switch to a large repo and find the average time before and after changes.
- `bin/compare`: compare the speed and output of Classification and `git ls-files`.
  (suppressing differences that are because of known [limitations](#limitations))

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
