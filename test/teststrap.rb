require 'pathname'
require 'rack/mock'
require 'rack/static'
require 'rack/file'

require File.expand_path('../../lib/rack-esi', __FILE__)
Bundler.require :development

Nokogiri

def html(body)
  Nokogiri.HTML(body).root
end

class App
  def call(env)
    Rack::Response.new.finish
  end
end

include Rack
