# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/ripl/color_result"
 
Gem::Specification.new do |s|
  s.name        = "ripl-color_result"
  s.version     = Ripl::ColorResult::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = "http://github.com/janlelis/ripl-color_result"
  s.summary = "A ripl plugin to colorize ripl results."
  s.description =  "This ripl plugin colorizes ripl results."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'ripl', '>= 0.4.1'
  s.add_dependency 'wirb', '>= 0.4.0'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "COPYING"]
  s.license = 'MIT'
end
