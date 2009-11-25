require 'pathname'
require 'rubygems'
require 'riot'
require 'rack-esi'
require 'rack/mock'

def html(body)
  Nokogiri.HTML(body).root
end

class App
  def call(env)
    Rack::Response.new.finish
  end
end

include Rack
