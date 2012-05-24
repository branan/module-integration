# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "module_acceptance"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Branan Purvine-Riley"]
  s.email       = ["branan@puppetlabs.com"]
  s.homepage    = "http://github.com/branan/module_acceptance"
  s.summary     = "Glue for Puppet module acceptance testing"
  s.description = "module_acceptance creates a virtual machine using veewee and vagrant and then runs acceptance tests."
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_dependency("veewee", ">= 0.3.0.alpha8")
  s.add_dependency("vagrant", ">= 1.0.0")
 
  s.files        = Dir.glob("{data,lib}/**/*") + %w(LICENSE)
  s.require_path = 'lib'
end
