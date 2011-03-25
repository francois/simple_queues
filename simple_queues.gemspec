# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_queues/version"

Gem::Specification.new do |s|
  s.name        = "simple_queues"
  s.version     = SimpleQueues::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["François Beausoleil"]
  s.email       = ["francois@teksol.info"]
  s.homepage    = "https://github.com/francois/simple_queues"
  s.summary     = %q{Simple enqueue/dequeue API for working with queues}
  s.description = %q{Program to an interface, not an implementation - hides Redis (used as a queue) behind a simple interface}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'RedCloth'
  s.add_development_dependency 'ruby-debug19'
  s.add_development_dependency 'msgpack'
  s.add_development_dependency 'json'
end
