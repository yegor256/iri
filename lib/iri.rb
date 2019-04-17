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
# Copyright:: Copyright (c) 2019 Yegor Bugayenko
# License:: MIT
class Iri
  # Makes a new object.
  def initialize(uri)
    @uri = URI(uri)
  end

  def to_s
    @uri.to_s
  end

  def to_uri
    @uri.clone
  end

  def add(hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k.to_s]
        params[k.to_s] << v
      end
    end
  end

  def del(*keys)
    modify_query do |params|
      keys.each do |k|
        params.delete(k.to_s)
      end
    end
  end

  # Replace the query argument(s).
  def over(hash)
    modify_query do |params|
      hash.each do |k, v|
        params[k.to_s] = [] unless params[k]
        params[k.to_s] = [v]
      end
    end
  end

  # Replace the scheme.
  def scheme(val)
    modify do |c|
      c.scheme = val
    end
  end

  # Replace the host.
  def host(val)
    modify do |c|
      c.host = val
    end
  end

  # Replace the port.
  def port(val)
    modify do |c|
      c.port = val
    end
  end

  # Replace the path part of the URI.
  def path(val)
    modify do |c|
      c.path = val
    end
  end

  # Replace the query part of the URI.
  def query(val)
    modify do |c|
      c.query = val
    end
  end

  # Remove the entire path+query+fragment part.
  def cut(path = '/')
    modify do |c|
      c.query = nil
      c.path = path
      c.fragment = nil
    end
  end

  private

  def modify
    c = @uri.clone
    yield c
    Iri.new(c)
  end

  def modify_query
    modify do |c|
      params = CGI.parse(@uri.query || '').map { |p, a| [p.to_s, a.clone] }.to_h
      yield(params)
      c.query = URI.encode_www_form(params)
    end
  end
end
