# rack-esi

Nokogiri based ESI middleware implementation for Rack with (limited) support
for include, remove and comment.

## Features

 * path blacklisting (:skip => nil, expects Regexp)
 * type whitelisting (:only => /^text\/(?:x|ht)ml/)
 * recursion limit (:depth => 5)
 * include limits (:includes => 32)
 * support for &lt;include&gt; alt and noerror attributes

_It's for development purpose..._

## Installation

    gem install rack-esi

## Rails Setup (environment.rb)

    config.gem 'rack-esi'
    require 'rack-esi'
    config.middleware.insert_before config.middleware.first, Rack::ESI

## TODO

 * write documentation
 * write more tests
 * support more ESI elements

## Dependencies

 * Rack
 * Nokogiri
 ... **and a xmlns:esi="http://www.edge-delivery.org/esi/1.0" declaration around your esi nodes.**

## Note on Patches/Pull Requests
 
 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a
  future version unintentionally.
 * Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
 * Send me a pull request. Bonus points for topic branches.

## Thanks

tenderlove and Qerub

## Copyright

Copyright (c) 2009 Florian Assmann. See LICENSE for details.
