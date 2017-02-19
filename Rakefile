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

desc 'build .pb.rb from caffe proto'
task :proto, [:caffe] do |_, args|
  ENV['CAFFE'] = args.caffe unless args.caffe.nil?
  ruby 'proto/compile.rb'
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
  sh "caffe train -solver #{test_solver}"
  src = Dir["#{net}/*_*.caffemodel"][0]
  mv src, model
  rm Dir["#{net}/*.solverstate"]
end

task spec: [model]

desc 'test the gem'
task test: [:rubocop, :proto, :compile, :spec]

task build: [:test]
