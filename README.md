# Classy

A .gitignore-inspired CLI tool for managing classification of files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "classy", github: "ltk/classy"
```

And then execute:

```sh
$ bundle
$ bundle binstubs classy
```

## Usage

By default, Classy considers all files to be `classified`. You can indicate that certain files are `unclassified` via rules defined in `.unclassified` files.

### .unclassified Files

`.unclassified` files work the same way as `.gitignore` files. They can exist at any level in a directory tree. If a file matches a rule within your `.unclassified` file, it will be considered `unclassified`.

### CLI

A CLI tool is provided as a binstub named `cls`. To execute it, run `bundle exec cls`.

#### `ls`

Lists all `unclassified` file paths in your directory. Similar to `git ls-files`.

e.g. `bundle exec cls ls`

#### `test`

Returns the classification of the specified file.

e.g. `bundle exec cls test README.md`
