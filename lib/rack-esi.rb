require 'rack'
require 'nokogiri'
require 'bundler'
Bundler.require

require File.expand_path('../rack-esi/processor', __FILE__)

class Rack::ESI

  def initialize(app, options = {})
    @app        = app

    @parser     = options.fetch :parser, Nokogiri::XML::Document
    @serializer = options.fetch :serializer, :to_xhtml
    @skip       = options[:skip]
    @poolsize   = options.fetch :poolsize, 4
    @processor  = @poolsize == 1 ? Processor::Linear : Processor::Threaded
  end

  def queue(&block)
    unless @queue
      @queue, @group = Queue.new, ThreadGroup.new
      @poolsize.times { @group.add Worker.new(@queue) }

      at_exit { Finisher.wait @queue }
    end

    @queue.push block
  end

  attr_reader :parser, :serializer

  def call(env)
    return @app.call(env) if @skip === env['PATH_INFO']

    status, headers, body = app.call env.dup

    if status == 200 and headers['Content-Type'] =~ /text\/html/
      body = @processor.new(self, env).process body
    end

    return status, headers, body
  end

end
