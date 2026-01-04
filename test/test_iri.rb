# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2019-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require_relative '../test/test__helper'
require_relative '../lib/iri'

# Iri test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2019-2026 Yegor Bugayenko
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
      .port(8080)
      .to_s
    assert_equal('https://localhost:8080/?q=books+about+tennis&limit=10', url)
  end

  def test_converts_to_uri
    assert_equal(
      'https://alpha.local?t=1',
      Iri.new('https://alpha.local').over(t: 1).to_uri.to_s
    )
  end

  def test_hides_https_port_number
    assert_equal(
      'https://google.com/abc',
      Iri.new('https://google.com').port(443).append('abc').to_s
    )
  end

  def test_converts_to_local
    {
      'http://localhost:9292/' => '/',
      'https://google.com/' => '/',
      'https://google.com/foo' => '/foo',
      'https://google.com/bar?x=900' => '/bar?x=900',
      'https://google.com/what#yes' => '/what#yes',
      'https://google.com/what?a=8&b=9#yes' => '/what?a=8&b=9#yes'
    }.each { |a, b| assert_equal(b, Iri.new(a).to_local.to_s) }
  end

  def test_deals_with_local
    assert_equal('/foo?x=1', Iri.new('https://google.com/foo').to_local.add(x: 1).to_s)
  end

  def test_broken_uri
    assert_raises Iri::InvalidURI do
      Iri.new('https://example.com/>', safe: false).add(a: 1)
    end
  end

  def test_incorrect_call_of_add
    assert_raises Iri::InvalidArguments do
      Iri.new('https://example.com/').add('hello5')
    end
  end

  def test_incorrect_call_of_over
    assert_raises Iri::InvalidArguments do
      Iri.new('https://example5.com/').over('boom44')
    end
  end

  def test_broken_uri_in_safe_mode
    Iri.new('https://example.com/>>>').add(a: 1)
  end

  def test_starts_with_empty_uri
    assert_equal(
      'https:',
      Iri.new.scheme('https').to_s
    )
  end

  def test_inspects_iri
    assert_equal(
      '"https://openai.com"',
      Iri.new('https://openai.com').inspect
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
      'http://localhost/a/b#test%20me',
      Iri.new('http://localhost/a/b#before').fragment('test me').to_s
    )
    assert_equal(
      'http://localhost/#42',
      Iri.new('http://localhost/').fragment(42).to_s
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
      'http://google/a/b/z+%2F+7/42?x=3',
      Iri.new('http://google/a/b?x=3').append('z / 7').append(42.to_s).to_s
    )
  end

  def test_appends_to_empty_ending
    assert_equal(
      'http://google.com/hello',
      Iri.new('http://google.com/').append('hello').to_s
    )
  end

  def test_appends_empty_path
    assert_equal(
      'http://google.com/test',
      Iri.new('http://google.com/hello').cut.append('test').to_s
    )
  end

  def test_replaces_query_param
    assert_equal(
      'http://google/?a=hey&b=2&c=3',
      Iri.new('http://google/?a=1&b=2&c=3&a=33').over(a: 'hey').to_s
    )
  end

  def test_rejects_nil_uri
    assert_raises ArgumentError do
      Iri.new(nil)
    end
  end

  def test_makes_uri_global
    assert_equal(
      'https://google.com/hello',
      Iri.new('/hello').scheme('https').host('google.com').to_s
    )
  end

  def test_rejects_nil_scheme
    assert_raises ArgumentError do
      Iri.new('http://google.com').scheme(nil)
    end
  end

  def test_rejects_nil_host
    assert_raises ArgumentError do
      Iri.new('http://google.com').host(nil)
    end
  end

  def test_rejects_nil_port
    assert_raises ArgumentError do
      Iri.new('http://google.com').port(nil)
    end
  end

  def test_rejects_nil_path
    assert_raises ArgumentError do
      Iri.new('http://google.com').path(nil)
    end
  end

  def test_rejects_nil_fragment
    assert_raises ArgumentError do
      Iri.new('http://google.com').fragment(nil)
    end
  end

  def test_rejects_nil_query
    assert_raises ArgumentError do
      Iri.new('http://google.com').query(nil)
    end
  end

  def test_rejects_nil_cut_path
    assert_raises ArgumentError do
      Iri.new('http://google.com/foo').cut(nil)
    end
  end

  def test_rejects_nil_append_part
    assert_raises ArgumentError do
      Iri.new('http://google.com').append(nil)
    end
  end

  def test_rejects_nil_add_hash
    assert_raises ArgumentError do
      Iri.new('http://google.com').add(nil)
    end
  end

  def test_rejects_nil_over_hash
    assert_raises ArgumentError do
      Iri.new('http://google.com').over(nil)
    end
  end

  def test_adds_nio
    assert_equal(
      'http://google.com/?b=10',
      Iri.new('http://google.com/').add(a: nil, b: 10).to_s
    )
  end

  def test_with_alias_for_add
    assert_equal(
      'http://google.com?q=test&limit=10',
      Iri.new('http://google.com').with(q: 'test', limit: 10).to_s
    )
  end

  def test_without_alias_for_del
    assert_equal(
      'http://google.com/?b=2',
      Iri.new('http://google.com/?a=1&b=2&c=3').without(:a, :c).to_s
    )
  end
end
