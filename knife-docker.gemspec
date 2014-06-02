$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-docker/version'

Gem::Specification.new do |s|
  s.name = "knife-docker"
  s.version = Knife::Docker::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Emanuele Rocca", "Pasha Sadikov"]
  s.summary = "Chef's Knife plugin to create and bootstrap Docker containers"
  s.description = s.summary
  s.email = "ema@linux.it"
  s.licenses = ["Apache 2.0"]
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = %w(LICENSE README.md) + Dir.glob("lib/**/*")
  s.homepage = "http://github.com/ema/knife-docker"
  s.require_paths = ["lib"]
  s.add_dependency(%q<chef>, [">= 0.10.0"])
end
