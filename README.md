[![EO principles respected here](http://www.elegantobjects.org/badge.svg)](http://www.elegantobjects.org)
[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/iri)](http://www.rultor.com/p/yegor256/iri)
[![We recommend RubyMine](http://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![Build Status](https://travis-ci.org/yegor256/iri.svg)](https://travis-ci.org/yegor256/iri)
[![Build status](https://ci.appveyor.com/api/projects/status/7eday736u9phnjiy?svg=true)](https://ci.appveyor.com/project/yegor256/iri)
[![Gem Version](https://badge.fury.io/rb/iri.svg)](http://badge.fury.io/rb/iri)
[![Maintainability](https://api.codeclimate.com/v1/badges/c136afe340fa94f14696/maintainability)](https://codeclimate.com/github/yegor256/iri/maintainability)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/yegor256/iri/master/frames)

Class `Iri` helps you build a URI and then modify its
parts via a simple fluent interface:

```ruby
url = Iri.new('http://google.com/')
  .add(q: 'books about OOP', limit: 50)
  .del(:q) # remove this query parameter
  .del('limit') # remove this one too
  .over(q: 'books about tennis', limit: 10) # replace these params
  .scheme('https')
  .host('localhost')
  .port('443')
  .to_s
```

Install it:

```bash
$ gem install iri
```

Or add this to your `Gemfile`:

```bash
gem 'iri'
```

That's it.

# How to contribute

Read [these guidelines](https://www.yegor256.com/2014/04/15/github-guidelines.html).
Make sure you build is green before you contribute
your pull request. You will need to have [Ruby](https://www.ruby-lang.org/en/) 2.3+ and
[Bundler](https://bundler.io/) installed. Then:

```
$ bundle update
$ bundle exec rake
```

If it's clean and you don't see any error messages, submit your pull request.
