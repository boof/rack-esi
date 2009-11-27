require 'rack'
require 'nokogiri'

class Rack::ESI
  NS = { 'esi' => 'http://www.edge-delivery.org/esi/1.0' }
  METHODS = { 'include' => :esi_include, 'remove' => nil, 'comment' => nil }
  CSS = METHODS.keys.map { |cmd| "esi|#{ cmd }" } * ','

  class Error < RuntimeError
    def initialize(status, headers, response)
      @status, @headers, @response = status, headers, response
    end
    def finish
      return [@status, @headers, backtrace]
    end
  end

  def initialize(app, options = {})
    @app  = app

    @paths          = options[:skip]
    @types          = options[:only] || /^text\/(?:x|ht)ml/
    @max_includes   = options[:includes] || 32
    @max_recursion  = options[:depth] || 5
  end

  def call env, counter = { :recursion => 0, :includes => 0 }
    return @app.call(env) if skip_path? env['PATH_INFO']

    status, headers, input = @app.call env.dup
    return status, headers, input if skip_type? headers['Content-Type']

    output = []
    input.each { |body| output << compile_body(body, env, counter) }

    Rack::Response.new(output, status, headers).finish
  end

  private

    def with_compiled_path(env, path)
      # TODO: should compile variables.
      env.merge 'PATH_INFO' => path, 'REQUEST_URI' => path
    end

    def fetch(path, env, counter)
      call with_compiled_path(env, path), counter if path
    rescue => e
      return [500, {}, e.backtrace]
    end

    # Should I use XML::SAX::Parser?
    def compile_body(body, env, counter)
      document = Nokogiri.XML body

      document.css(CSS, NS).each do |node|
        method = METHODS[node.name] and send method, node, env, counter
        node.unlink
      end

      document.to_xhtml
    end

    def skip_path?(path)
      @paths =~ path if @paths
    end
    def skip_type?(type)
      @types !~ type
    end

    def max?(counter)
      not counter[:includes] < @max_includes &&
          counter[:recursion] < @max_recursion
    end

    def esi_include(node, env, counter)
      return if max? counter

      counter[:includes] += 1
      counter[:recursion] += 1

      status, headers, response = fetch node['src'], env, counter
      status, headers, response = fetch node['alt'], env, counter if status != 200

      if status == 200
        data = ''
        response.each { |inc| data << inc }
        node.before data
      elsif node['onerror'] != 'continue'
        raise Error.new(status, headers, response)
      end

    ensure
      counter[:recursion] -= 1
    end

end
