# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2019-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'uri'
require 'cgi'

# Iri is a simple, immutable URI builder with a fluent interface.
#
# The Iri class provides methods to manipulate different parts of a URI,
# including the scheme, host, port, path, query parameters, and fragment.
# Each method returns a new Iri instance, maintaining immutability.
#
# @example Creating and manipulating a URI
#   require 'iri'
#   url = Iri.new('http://google.com/')
#     .add(q: 'books about OOP', limit: 50)
#     .del(:q) # remove this query parameter
#     .del('limit') # remove this one too
#     .over(q: 'books about tennis', limit: 10) # replace these params
#     .scheme('https')
#     .host('localhost')
#     .port('443')
#     .to_s
#
# @example Using the local option
#   Iri.new('/path?foo=bar', local: true).to_s # => "/path?foo=bar"
#
# @example Using the safe mode
#   Iri.new('invalid://uri', safe: true).to_s # => "/" (no exception thrown)
#   Iri.new('invalid://uri', safe: false) # => raises Iri::InvalidURI
#
# For more information read the
# {README}[https://github.com/yegor256/iri/blob/master/README.md] file.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2019-2025 Yegor Bugayenko
# License:: MIT
class Iri
  # Exception raised when a URI is not valid and safe mode is disabled.
  class InvalidURI < StandardError; end

  # Exception raised when arguments to .add(), .over(), or .del() are not valid Hashes.
  class InvalidArguments < StandardError; end

  # Creates a new Iri object for URI manipulation.
  #
  # You can even ignore the argument, which will produce an empty URI ("/").
  #
  # By default, this class will never throw any exceptions, even if your URI
  # is not valid. It will just assume that the URI is "/". However,
  # you can turn this safe mode off by specifying safe as FALSE, which will
  # cause InvalidURI to be raised if the URI is malformed.
  #
  # The local parameter can be used if you only want to work with the path,
  # query, and fragment portions of a URI, without the scheme, host, and port.
  #
  # @param [String] uri URI string to parse
  # @param [Boolean] local When true, ignores scheme, host and port parts
  # @param [Boolean] safe When true, prevents InvalidURI exceptions
  # @raise [InvalidURI] If the URI is malformed and safe is false
  def initialize(uri = '', local: false, safe: true)
    @uri = uri
    @local = local
    @safe = safe
  end

  # Converts the Iri object to a string representation of the URI.
  #
  # When local mode is enabled, only the path, query, and fragment parts are included.
  # Otherwise, the full URI including scheme, host, and port is returned.
  #
  # @return [String] String representation of the URI
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

  # Returns a string representation of the Iri object for inspection purposes.
  #
  # This method is used when the object is displayed in irb/console or with puts/p.
  #
  # @return [String] String representation for inspection
  def inspect
    @uri.to_s.inspect
  end

  # Converts the Iri object to a Ruby standard library URI object.
  #
  # @return [URI] A cloned URI object from the underlying URI
  def to_uri
    the_uri.clone
  end

  # Creates a new Iri object with only the local parts of the URI.
  #
  # Removes the host, the port, and the scheme, returning only the local address.
  # For example, converting "https://google.com/foo" into "/foo".
  # The path, query string, and fragment are preserved.
  #
  # @return [Iri] A new Iri object with local:true and the same URI
  # @see #initialize
  def to_local
    Iri.new(@uri, local: true, safe: @safe)
  end

  # Adds query parameters to the URI.
  #
  # This method appends query parameters to existing ones. If a parameter with the same
  # name already exists, both values will be present in the resulting URI.
  #
  # @example Adding query parameters
  #   Iri.new('https://google.com').add(q: 'test', limit: 10)
  #   # => "https://google.com?q=test&limit=10"
  #
  # @example Adding parameters with the same name
  #   Iri.new('https://google.com?q=foo').add(q: 'bar')
  #   # => "https://google.com?q=foo&q=bar"
  #
  # You can ensure only one instance of a parameter by using +del+ first:
  #
  # @example Replacing a parameter by deleting it first
  #   Iri.new('https://google.com?q=foo').del(:q).add(q: 'test')
  #   # => "https://google.com?q=test"
  #
  # @param [Hash] hash Hash of parameter names/values to add to the query part
  # @return [Iri] A new Iri instance
  # @raise [InvalidArguments] If the argument is not a Hash
  # @see #del
  # @see #over
  def add(hash)
    raise InvalidArguments unless hash.is_a?(Hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k.to_s]
        params[k.to_s] << v
      end
    end
  end

  # Deletes query parameters from the URI.
  #
  # This method removes all instances of the specified parameters from the query string.
  #
  # @example Deleting a query parameter
  #   Iri.new('https://google.com?q=test&limit=10').del(:q)
  #   # => "https://google.com?limit=10"
  #
  # @example Deleting multiple parameters
  #   Iri.new('https://google.com?q=test&limit=10&sort=asc').del(:q, :limit)
  #   # => "https://google.com?sort=asc"
  #
  # @param [Array<Symbol, String>] keys List of parameter names to delete
  # @return [Iri] A new Iri instance
  # @see #add
  # @see #over
  def del(*keys)
    modify_query do |params|
      keys.each do |k|
        params.delete(k.to_s)
      end
    end
  end

  # Replaces query parameters in the URI.
  #
  # Unlike #add, this method replaces any existing parameters with the same name
  # rather than adding additional instances. If a parameter doesn't exist,
  # it will be added.
  #
  # @example Replacing a query parameter
  #   Iri.new('https://google.com?q=test').over(q: 'hey you!')
  #   # => "https://google.com?q=hey+you%21"
  #
  # @example Replacing multiple parameters
  #   Iri.new('https://google.com?q=test&limit=5').over(q: 'books', limit: 10)
  #   # => "https://google.com?q=books&limit=10"
  #
  # @param [Hash] hash Hash of parameter names/values to replace in the query part
  # @return [Iri] A new Iri instance
  # @raise [InvalidArguments] If the argument is not a Hash
  # @see #add
  # @see #del
  def over(hash)
    raise InvalidArguments unless hash.is_a?(Hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k.to_s]
        params[k.to_s] = [v]
      end
    end
  end

  # Replaces the scheme part of the URI.
  #
  # @example Changing the scheme
  #   Iri.new('http://google.com').scheme('https')
  #   # => "https://google.com"
  #
  # @param [String] val New scheme to set, like "https" or "http"
  # @return [Iri] A new Iri instance
  # @see #host
  # @see #port
  def scheme(val)
    modify do |c|
      c.scheme = val
    end
  end

  # Replaces the host part of the URI.
  #
  # @example Changing the host
  #   Iri.new('https://google.com').host('example.com')
  #   # => "https://example.com"
  #
  # @param [String] val New host to set, like "example.com" or "192.168.0.1"
  # @return [Iri] A new Iri instance
  # @see #scheme
  # @see #port
  def host(val)
    modify do |c|
      c.host = val
    end
  end

  # Replaces the port part of the URI.
  #
  # @example Changing the port
  #   Iri.new('https://example.com').port('8443')
  #   # => "https://example.com:8443"
  #
  # @param [String] val New TCP port to set, like "8080" or "443"
  # @return [Iri] A new Iri instance
  # @see #scheme
  # @see #host
  def port(val)
    modify do |c|
      c.port = val
    end
  end

  # Replaces the path part of the URI.
  #
  # @example Changing the path
  #   Iri.new('https://example.com/foo').path('/bar/baz')
  #   # => "https://example.com/bar/baz"
  #
  # @param [String] val New path to set, like "/foo/bar"
  # @return [Iri] A new Iri instance
  # @see #query
  # @see #fragment
  def path(val)
    modify do |c|
      c.path = val
    end
  end

  # Replaces the fragment part of the URI (the part after #).
  #
  # @example Setting a fragment
  #   Iri.new('https://example.com/page').fragment('section2')
  #   # => "https://example.com/page#section2"
  #
  # @param [String] val New fragment to set, like "section2"
  # @return [Iri] A new Iri instance
  # @see #path
  # @see #query
  def fragment(val)
    modify do |c|
      c.fragment = val.to_s
    end
  end

  # Replaces the entire query part of the URI.
  #
  # Use this method to completely replace the query string. For modifying
  # individual parameters, see #add, #del, and #over.
  #
  # @example Setting a query string
  #   Iri.new('https://example.com/search').query('q=ruby&limit=10')
  #   # => "https://example.com/search?q=ruby&limit=10"
  #
  # @param [String] val New query string to set, like "a=1&b=2"
  # @return [Iri] A new Iri instance
  # @see #add
  # @see #del
  # @see #over
  def query(val)
    modify do |c|
      c.query = val
    end
  end

  # Removes the entire path, query, and fragment parts and sets a new path.
  #
  # This method is useful for "cutting off" everything after the host:port
  # and setting a new path, effectively removing query string and fragment.
  #
  # @example Cutting off path/query/fragment and setting a new path
  #   Iri.new('https://google.com/a/b?q=test').cut('/hello')
  #   # => "https://google.com/hello"
  #
  # @example Resetting to root path
  #   Iri.new('https://google.com/a/b?q=test#section2').cut()
  #   # => "https://google.com/"
  #
  # @param [String] path New path to set, defaults to "/"
  # @return [Iri] A new Iri instance
  # @see #path
  # @see #query
  # @see #fragment
  def cut(path = '/')
    modify do |c|
      c.query = nil
      c.path = path
      c.fragment = nil
    end
  end

  # Appends a new segment to the existing path.
  #
  # This method adds a new segment to the existing path, automatically handling
  # the slash between segments and URL encoding the new segment.
  #
  # @example Appending a path segment
  #   Iri.new('https://example.com/a/b?q=test').append('hello')
  #   # => "https://example.com/a/b/hello?q=test"
  #
  # @example Appending to a path with a trailing slash
  #   Iri.new('https://example.com/a/').append('hello')
  #   # => "https://example.com/a/hello?q=test"
  #
  # @example Appending a segment that needs URL encoding
  #   Iri.new('https://example.com/docs').append('section 1')
  #   # => "https://example.com/docs/section%201"
  #
  # @param [String, #to_s] part New segment to add to the existing path
  # @return [Iri] A new Iri instance
  # @see #path
  def append(part)
    modify do |c|
      tail = (c.path.end_with?('/') ? '' : '/') + CGI.escape(part.to_s)
      c.path = c.path + tail
    end
  end

  private

  # Parses the URI string into a URI object.
  #
  # This method handles the safe mode by catching and handling invalid URI errors.
  # When safe mode is enabled (default), invalid URIs will return the root path URI "/"
  # instead of raising an exception.
  #
  # @return [URI] The parsed URI object
  # @raise [InvalidURI] If the URI is invalid and safe mode is disabled
  def the_uri
    @the_uri ||= URI(@uri)
  rescue URI::InvalidURIError => e
    raise InvalidURI, e.message unless @safe
    @the_uri = URI('/')
  end

  # Creates a new Iri object after modifying the underlying URI.
  #
  # This helper method clones the current URI, yields it to a block for modification,
  # and then creates a new Iri object with the modified URI, preserving the local and safe flags.
  #
  # @yield [URI] The cloned URI object for modification
  # @return [Iri] A new Iri instance with the modified URI
  def modify
    c = the_uri.clone
    yield c
    Iri.new(c, local: @local, safe: @safe)
  end

  # Creates a new Iri object after modifying the query parameters.
  #
  # This helper method parses the current query string into a hash of parameter names
  # to arrays of values, yields this hash for modification, and then encodes it back
  # into a query string. It uses the modify method to create a new Iri object.
  #
  # @yield [Hash] The parsed query parameters for modification
  # @return [Iri] A new Iri instance with the modified query string
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
