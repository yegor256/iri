# frozen_string_literal: true

# (The MIT License)
#
# Copyright (c) 2019 Yegor Bugayenko
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

require 'minitest/autorun'
require_relative '../lib/iri'

# Iri test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2019 Yegor Bugayenko
# License:: MIT
class IriTest < Minitest::Test
  def test_builds_uri
    url = Iri.new('http://google.com/')
      .add(q: 'books about OOP', limit: 50)
      .del(:q)
      .del('limit')
      .over(q: 'books about tennis', limit: 10)
      .scheme('https')
      .host('localhost')
      .port('443')
      .to_s
    assert_equal('https://localhost:443/?q=books+about+tennis&limit=10', url)
  end

  def test_starts_with_empty_uri
    assert_equal(
      'https:',
      Iri.new.scheme('https').to_s
    )
  end

  def test_replaces_scheme
    assert_equal(
      'https://google.com/',
      Iri.new('http://google.com/').scheme('https').to_s
    )
  end

  def test_replaces_host
    assert_equal(
      'http://localhost/',
      Iri.new('http://google.com/').host('localhost').to_s
    )
  end

  def test_replaces_port
    assert_equal(
      'http://localhost:443/',
      Iri.new('http://localhost/').port(443).to_s
    )
  end

  def test_replaces_fragment
    assert_equal(
      'http://localhost/a/b#test',
      Iri.new('http://localhost/a/b#before').fragment('test').to_s
    )
  end

  def test_sets_path
    assert_equal(
      'http://localhost/hey/you?i=8#test',
      Iri.new('http://localhost/hey?i=8#test').path('/hey/you').to_s
    )
  end

  def test_sets_query
    assert_equal(
      'http://localhost/hey?t=1#test',
      Iri.new('http://localhost/hey?i=8#test').query('t=1').to_s
    )
  end

  def test_removes_path
    assert_equal(
      'http://localhost/',
      Iri.new('http://localhost/hey?i=8#test').cut.to_s
    )
  end

  def test_adds_query_param
    assert_equal(
      'http://google/?a=1&a=3&b=2',
      Iri.new('http://google/').add(a: 1, b: 2).add(a: 3).to_s
    )
    assert_equal(
      'http://google/?%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82+%D0%B4%D1%80%D1%83%D0%B3=%D0%BA%D0%B0%D0%BA+%D0%B4%D0%B5%D0%BB%D0%B0%3F',
      Iri.new('http://google/').add('привет друг' => 'как дела?').to_s
    )
  end

  def test_removes_query_param
    assert_equal(
      'http://google/?b=2&c=3',
      Iri.new('http://google/?a=1&b=2&c=3&a=3').del('a').del('x').to_s
    )
  end

  def test_appends_path
    assert_equal(
      'http://google/a/b/z+%2F+7?x=3',
      Iri.new('http://google/a/b?x=3').append('z / 7').to_s
    )
  end

  def test_replaces_query_param
    assert_equal(
      'http://google/?a=hey&b=2&c=3',
      Iri.new('http://google/?a=1&b=2&c=3&a=33').over(a: 'hey').to_s
    )
  end
end
