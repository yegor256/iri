# Immutable URI Builder for Ruby

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![DevOps By Rultor.com](https://www.rultor.com/b/yegor256/iri)](https://www.rultor.com/p/yegor256/iri)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/iri/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/iri/actions/workflows/rake.yml)
[![Gem Version](https://badge.fury.io/rb/iri.svg)](https://badge.fury.io/rb/iri)
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/github/yegor256/iri/master/frames)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/iri/blob/master/LICENSE.txt)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/iri.svg)](https://codecov.io/github/yegor256/iri?branch=master)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/iri)](https://hitsofcode.com/view/github/yegor256/iri)

The class [Iri] helps you build a URI and then modify its
  parts via a simple [fluent interface]:

```ruby
require 'iri'
url = Iri.new('http://google.com/')
  .append('find').append('me') # -> http://google.com/find/me
  .with(q: 'books about OOP', limit: 50) # -> ?q=books+about+OOP&limit=50
  .without(:q) # remove this query parameter
  .without('limit', 'speed') # also remove these two
  .over(q: 'books about tennis', limit: 10) # replace these params
  .scheme('https') # replace 'http' with 'https'
  .host('localhost') # replace the host name
  .port('443') # replace the port
  .fragment('page-4') # replaces the fragment part of the URI, after the '#'
  .query('a=1&b=2') # replaces the entire query part of the URI
  .path('/new/path') # replace the path of the URI, leaving the query untouched
  .cut('/q') # replace everything after the host and port
  .to_s # convert it to a string
```

See the
[full list of methods](https://www.rubydoc.info/github/yegor256/iri/master/Iri).

Install it:

```bash
gem install iri
```

Or add this to your `Gemfile`:

```ruby
gem 'iri'
```

Pay attention, it is not a parser. The only functionality this gem provides
is _building_ URIs.

It is very convenient to use inside
[HAML](http://haml.info/tutorial.html), for example:

```haml
- iri = Iri.new(request.url)
%a{href: iri.over(offset: offset + 10)} Next Page
%a{href: iri.over(offset: offset - 10)} Previous Page
```

Of course, it's better to create the `iri` object only once per request
and re-use it where you need. It's _immutable_, so you won't have any
side-effects.

PS. See how I use it in this Sinatra web app:
[yegor256/0rsk](https://github.com/yegor256/0rsk).

## How to contribute

Read
[these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure your build is green before you contribute
your pull request. You will need to have
[Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```bash
bundle update
bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.

[Iri]: https://www.rubydoc.info/github/yegor256/iri/master/Iri
[fluent interface]: https://en.wikipedia.org/wiki/Fluent_interface
