# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "passive_resource/version"
require "passive_resource/base"

Gem::Specification.new do |s|
  s.name        = "passive_resource"
  s.version     = PassiveResource::VERSION
  s.authors     = ["Grady Griffin"]
  s.email       = ["gradyg@izea.com"]
  s.homepage    = ""
  s.summary     = %q{Simple objects from json}
  s.description = %q{Creates Ruby objects from JSON requested from apis or hashes}

  s.rubyforge_project = "passive_resource"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    s.add_dependency("active_support", '~> 2.3')
    s.add_dependency "rest-client"
    s.add_dependency "rspec"
  else
    s.add_runtime_dependency("active_support", '~> 2.3')
    s.add_runtime_dependency "rest-client"
    s.add_development_dependency "rspec"
  end
end
