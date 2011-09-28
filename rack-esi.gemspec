# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack-esi/version"

Gem::Specification.new do |s|
  s.name        = "rack-esi"
  s.version     = Rack::ESI::VERSION
  s.authors     = ["Florian Aßmann"]
  s.email       = ["florian.assmann@email.de"]
  s.homepage    = ""
  s.summary     = %q{ ESI middleware implementation for Rack. }
  s.description = <<-EOF
Rack-ESI is a Nokogiri based ESI middleware implementation for Rack with support for include tags, all other ESI namespaced nodes are just removed.
To make this gem work you must define the (xmlns:esi)[http://www.edge-delivery.org/esi/1.0] namespace in your text/html response.
Note: This gem should only be used in development. For production use setup varnish or any other ESI enabled server.
EOF
  # s.rubyforge_project = "rack-esi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rack"
  s.add_dependency "nokogiri"
  # s.add_dependency "patron"
  s.add_development_dependency "riot"
end
