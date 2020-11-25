# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2019-2020 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'English'
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new('>= 0')
  end
  s.rubygems_version = '2.5'
  s.required_ruby_version = '>=2.2'
  s.name = 'iri'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.summary = 'Simple Immutable Ruby URI Builder'
  s.description = 'Class Iri helps you build a URI and then modify its \
parts via a simple fluent interface.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'http://github.com/yegor256/iri'
  s.files = `git ls-files`.split($RS)
  s.test_files = s.files.grep(%r{^(test)/})
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md']
  s.add_development_dependency 'codecov', '0.2.11'
  s.add_development_dependency 'minitest', '5.11.3'
  s.add_development_dependency 'rake', '12.3.3'
  s.add_development_dependency 'rdoc', '4.3.0'
  s.add_development_dependency 'rubocop', '0.62.0'
  s.add_development_dependency 'rubocop-rspec', '1.31.0'
end
