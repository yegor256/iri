# frozen_string_literal: true

# (The MIT License)
#
# SPDX-FileCopyrightText: Copyright (c) 2019-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'uri'
require 'cgi'

# It is a simple URI builder.
#
#  require 'iri'
#  url = Iri.new('http://google.com/')
#    .add(q: 'books about OOP', limit: 50)
#    .del(:q) // remove this query parameter
#    .del('limit') // remove this one too
#    .over(q: 'books about tennis', limit: 10) // replace these params
#    .scheme('https')
#    .host('localhost')
#    .port('443')
#    .to_s
#
# For more information read
# {README}[https://github.com/yegor256/iri/blob/master/README.md] file.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2019-2025 Yegor Bugayenko
# License:: MIT
class Iri
  # When URI is not valid.
  class InvalidURI < StandardError; end

  # When .add(), .over(), or .del() arguments are not valid.
  class InvalidArguments < StandardError; end

  # Makes a new object.
  #
  # You can even ignore the argument, which will produce an empty URI.
  #
  # By default, this class will never throw any exceptions, even if your URI
  # is not valid. It will just assume that the URI is"/". However,
  # you can turn this mode off, by specifying safe as FALSE.
  #
  # @param [String] uri URI
  # @param [Boolean] local Is it local (no host, port, and scheme)?
  # @param [Boolean] safe Should it safe?
  def initialize(uri = '', local: false, safe: true)
    @uri = uri
    @local = local
    @safe = safe
  end

  # Convert it to a string.
  #
  # @return [String] New URI
  def to_s
    u = the_uri
    if @local
      [
        u.path,
        u.query ? "?#{u.query}" : '',
        u.fragment ? "##{u.fragment}" : ''
      ].join
    else
      u.to_s
    end
  end

  # Inspect it, like a string can be inspected.
  #
  # @return [String] Details of it
  def inspect
    @uri.to_s.inspect
  end

  # Convert it to an object of class +URI+.
  #
  # @return [String] New URI
  def to_uri
    the_uri.clone
  end

  # Removes the host, the port, and the scheme and returns
  # only the local address, for example, converting "https://google.com/foo"
  # into "/foo".
  #
  # @return [Iri] Iri with no host/port/scheme
  def to_local
    Iri.new(@uri, local: true, safe: @safe)
  end

  # Add a few query arguments.
  #
  # For example:
  #
  #  Iri.new('https://google.com').add(q: 'test', limit: 10)
  #
  # You can add many of them and they will all be present in the resulting
  # URI, even if their names are the same. In order to make sure you have
  # only one instance of a query argument, use +del+ first:
  #
  #  Iri.new('https://google.com').del(:q).add(q: 'test')
  #
  # @param [Hash] hash Hash of names/values to set into the query part
  # @return [Iri] A new iri
  def add(hash)
    raise InvalidArguments unless hash.is_a?(Hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k.to_s]
        params[k.to_s] << v
      end
    end
  end

  # Delete a few query arguments.
  #
  # For example:
  #
  #  Iri.new('https://google.com?q=test').del(:q)
  #
  # @param [Array] keys List of keys to delete
  # @return [Iri] A new iri
  def del(*keys)
    modify_query do |params|
      keys.each do |k|
        params.delete(k.to_s)
      end
    end
  end

  # Replace query argument(s).
  #
  #  Iri.new('https://google.com?q=test').over(q: 'hey you!')
  #
  # @param [Hash] hash Hash of names/values to set into the query part
  # @return [Iri] A new iri
  def over(hash)
    raise InvalidArguments unless hash.is_a?(Hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k]
        params[k.to_s] = [v]
      end
    end
  end

  # Replace the scheme.
  #
  # @param [String] val New scheme to set, like "https" or "http"
  # @return [Iri] A new iri
  def scheme(val)
    modify do |c|
      c.scheme = val
    end
  end

  # Replace the host.
  #
  # @param [String] val New host to set, like "google.com" or "192.168.0.1"
  # @return [Iri] A new iri
  def host(val)
    modify do |c|
      c.host = val
    end
  end

  # Replace the port.
  #
  # @param [String] val New TCP port to set, like "8080" or "443"
  # @return [Iri] A new iri
  def port(val)
    modify do |c|
      c.port = val
    end
  end

  # Replace the path part of the URI.
  #
  # @param [String] val New path to set, like "/foo/bar"
  # @return [Iri] A new iri
  def path(val)
    modify do |c|
      c.path = val
    end
  end

  # Replace the fragment part of the URI.
  #
  # @param [String] val New fragment to set, like "hello"
  # @return [Iri] A new iri
  def fragment(val)
    modify do |c|
      c.fragment = val.to_s
    end
  end

  # Replace the query part of the URI.
  #
  # @param [String] val New query to set, like "a=1&b=2"
  # @return [Iri] A new iri
  def query(val)
    modify do |c|
      c.query = val
    end
  end

  # Remove the entire path+query+fragment part.
  #
  # For example:
  #
  #  Iri.new('https://google.com/a/b?q=test').cut('/hello')
  #
  # The result will contain "https://google.com/hello".
  #
  # @param [String] path New path to set, like "/foo"
  # @return [Iri] A new iri
  def cut(path = '/')
    modify do |c|
      c.query = nil
      c.path = path
      c.fragment = nil
    end
  end

  # Append something new to the path.
  #
  # For example:
  #
  #  Iri.new('https://google.com/a/b?q=test').append('/hello')
  #
  # The result will contain "https://google.com/a/b/hello?q=test".
  #
  # @param [String] part New segment to add to existing path
  # @return [Iri] A new iri
  def append(part)
    modify do |c|
      tail = (c.path.end_with?('/') ? '' : '/') + CGI.escape(part.to_s)
      c.path = c.path + tail
    end
  end

  private

  def the_uri
    @the_uri ||= URI(@uri)
  rescue URI::InvalidURIError => e
    raise InvalidURI, e.message unless @safe
    @the_uri = URI('/')
  end

  def modify
    c = the_uri.clone
    yield c
    Iri.new(c, local: @local, safe: @safe)
  end

  def modify_query
    modify do |c|
      params = CGI.parse(the_uri.query || '').map do |p, a|
        [p.to_s, a.clone]
      end.to_h
      yield(params)
      c.query = URI.encode_www_form(params)
    end
  end
end
