<img src="/logo.svg" width="64px" height="64px"/>

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/iri)](http://www.rultor.com/p/yegor256/iri)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/iri/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/iri/actions/workflows/rake.yml)
[![Gem Version](https://badge.fury.io/rb/iri.svg)](http://badge.fury.io/rb/iri)
[![Maintainability](https://api.codeclimate.com/v1/badges/7018d2fe438103828685/maintainability)](https://codeclimate.com/github/yegor256/iri/maintainability)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/yegor256/iri/master/frames)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/iri/blob/master/LICENSE.txt)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/iri.svg)](https://codecov.io/github/yegor256/iri?branch=master)
![Lines of code](https://img.shields.io/tokei/lines/github/yegor256/iri)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/iri)](https://hitsofcode.com/view/github/yegor256/iri)

The class [`Iri`](https://www.rubydoc.info/github/yegor256/iri/master/Iri)
helps you build a URI and then modify its
parts via a simple [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface):

```ruby
require 'iri'
url = Iri.new('http://google.com/')
  .append('find').append('me') # -> http://google.com/find/me
  .add(q: 'books about OOP', limit: 50) # -> ?q=books+about+OOP&limit=50
  .del(:q) # remove this query parameter
  .del('limit') # remove this one too
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

The full list of methods is [here](https://www.rubydoc.info/github/yegor256/iri/master/Iri).

Install it:

```bash
$ gem install iri
```

Or add this to your `Gemfile`:

```bash
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

PS. See how I use it in this Sinatra web app: [yegor256/0rsk](https://github.com/yegor256/0rsk).

## How to contribute

Read [these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have [Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```
$ bundle update
$ bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
