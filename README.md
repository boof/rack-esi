# rack-esi

Rack-ESI is a Nokogiri based ESI middleware implementation for Rack with support for include tags, all other ESI namespaced nodes are just removed.

To make this gem work you must define the [xmlns:esi](http://www.edge-delivery.org/esi/1.0) namespace in your text/html response.

Note: This gem should only be used in development. For production use setup varnish or any other ESI enabled server.

## Features

 * threaded (in case we have slow IOs)
 * PATH_INFO blacklisting (:skip => nil, should respond to ===)
 * support for esi|include[alt] and esi|include[noerror] fallbacks

## Dependencies

 * Nokogiri
 * Rack

## Setup

### w/o Gemfile

    $ gem install rack-esi

### w/ Gemfile

    gem 'rack-esi'

### rackup

    use Rack::ESI, options || {}
    run Application.new

### Rails (only tested with 3.1 so far): environment.rb

    config.gem 'rack-esi' # for setups w/o Gemfile
    config.middleware.insert_before Rails::Rack::Logger, Rack::ESI

## Options

 * poolsize: 4,
   Number of worker threads. A value of 1 disables threading model.
 * skip: nil,
   This should be an object which responds to #===(PATH_INFO).
 * parser: Nokogiri::XML::Document,
   You can change this to Nokogiri::HTML::Document, but you should change the serializer, too (see below).
 * serializer: :to_xhtml,
   The serializer value specifies the method name which is send to the object created by the parser#parse.

## TODO

 * write documentation
 * write more tests
 * support more ESI elements

## Note on Patches/Pull Requests
 
 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it.
 * Commit, do not mess with rakefile, version, or history.
 * Send me a pull request.

## Thanks

tenderlove and Qerub

## Copyright

Copyright (c) 2009 Florian Aßmann. See LICENSE for details.
