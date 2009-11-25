require 'rack'
require 'nokogiri'

class Rack::ESI
  NS = { 'esi' => 'http://www.edge-delivery.org/esi/1.0' }
  Error = Class.new RuntimeError

  def initialize(app, options = {})
    @app  = app

    @paths          = options[:skip]
    @types          = options[:only] || /^text\/(?:x|ht)ml/
    @max_includes   = options[:includes] || 32
    @max_recursion  = options[:depth] || 5
  end

  def call env, counter = { :recursion => 0, :includes => 0 }
    return @app.call(env) if skip_path? env['PATH_INFO']

    status, headers, source = @app.call env
    return status, headers, source if skip_type? headers['Content-Type']

    Rack::Response.new { |target|
      source.each { |body| target.write compile(body, env, counter) }
    }.finish
  end

  private

    def fetch(path, env, counter)
      call env.merge('PATH_INFO' => path), counter if path
    end

    # Should I use XML::SAX::Parser?
    def compile(body, env, counter)
      document = Nokogiri.XML body

      document.css('esi|include,esi|remove,esi|comment', NS).each do |node|
        case node.name
        when 'include'
          next unless counter[:includes] < @max_includes
          counter[:includes] += 1
          begin
            next unless counter[:recursion] < @max_recursion
            counter[:recursion] += 1
            status, headers, compiled = fetch node['src'], env, counter
            status, headers, compiled = fetch node['alt'], env, counter if status != 200
          ensure
            counter[:recursion] -= 1
          end

          if status != 200
            raise Error if node['onerror'] != 'continue'
            compiled = []
          end

          data = '' and compiled.each { |body| data << body }
          node.swap data

        when 'remove', 'comment'
          node.unlink
        end
      end

      document.to_xhtml
    end

    def skip_path?(path)
      @paths =~ path if @paths
    end
    def skip_type?(type)
      @types !~ type
    end

end
