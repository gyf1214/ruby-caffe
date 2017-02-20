require 'rake/extensiontask'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

Rake::ExtensionTask.new :caffe do |ext|
  ext.lib_dir = 'lib/caffe'
  ext.source_pattern = '*.{hpp,cc}'
end

RSpec::Core::RakeTask.new :spec

RuboCop::RakeTask.new

proto = 'lib/caffe/caffe.pb.rb'
compile = 'proto/compile.rb'

file proto do
  ruby compile
end

net = 'spec/net'
test_data = "#{net}/test_data"
test_solver = "#{net}/test_solver.prototxt"
gen_data = "#{net}/gen_data.rb"
model = "#{net}/test.caffemodel"

directory test_data
file test_data do
  ruby gen_data
end

file model => test_data do
  sh "caffe train -solver #{test_solver} > /dev/null 2>&1"
  src = Dir["#{net}/*_*.caffemodel"][0]
  mv src, model
  rm Dir["#{net}/*.solverstate"]
end

namespace :build do
  desc 'build .pb.rb from caffe proto'
  task proto: [proto]

  desc 'build trained model for testing'
  task model: [model]

  desc 'build all prerequisites for gem & test'
  task pre: [:proto, :model]
end

desc 'test the gem'
task test: [:rubocop, 'build:pre', :compile, :spec]

task build: [:test]

task :clobber do
  sh "rm -fr #{test_data} #{model}", verbose: false
  rm Dir[proto], verbose: false
end
