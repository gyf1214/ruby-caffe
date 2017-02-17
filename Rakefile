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

desc 'build proto & compile extension'
task build: [:proto, :compile]

desc 'test the gem'
task test: [:rubocop, :build, :spec]
