# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2019-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=2.2'
  s.name = 'iri'
  s.version = '0.11.6'
  s.license = 'MIT'
  s.summary = 'Simple Immutable Ruby URI Builder'
  s.description =
    'Class Iri helps you build a URI and then modify its ' \
    'parts via a simple immutable fluent interface. It always returns a new ' \
    'object instead of changing the existing one. This makes the object ' \
    'safer and much easier to reuse.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'https://github.com/yegor256/iri'
  s.files = `git ls-files | grep -v -E '^(test/|\\.|renovate)'`.split($RS)
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md']
  s.metadata['rubygems_mfa_required'] = 'true'
end
