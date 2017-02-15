require 'rake/extensiontask'
require 'rspec/core/rake_task'

Rake::ExtensionTask.new :caffe do |ext|
  ext.lib_dir = 'lib/caffe'
  ext.source_pattern = '*.{hpp,cc}'
end

RSpec::Core::RakeTask.new :spec

task :proto, [:caffe] do |t, args|
  ENV['CAFFE'] = args.caffe unless args.caffe.nil?
  ruby "proto/compile.rb"
end

task :build => [:proto, :compile]
task :test => [:build, :spec]
