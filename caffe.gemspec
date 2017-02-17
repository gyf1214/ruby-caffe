# encoding: UTF-8
$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'caffe/version'

Gem::Specification.new do |s|
  s.name          = 'caffe'
  s.version       = Caffe::VERSION
  s.date          = Time.now.strftime '%Y-%m-%d'
  s.license       = 'MIT'

  s.authors       = ['Tiny Tiny']
  s.email         = ['gyf1214@gmail.com']
  s.homepage      = 'https://github.com/gyf1214/ruby-caffe'
  s.summary       = 'A ruby wrapper of the deep leaning framework'
  s.description   = s.summary

  s.files         = `git ls-files`.split "\n"
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split "\n"
  s.require_paths = ['lib']
  s.extensions   += Dir['ext/**/extconf.rb']

  s.extra_rdoc_files = ['README.md', 'LICENSE']

  s.add_dependency 'rice'
  s.add_dependency 'protobuf'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rspec'
end
