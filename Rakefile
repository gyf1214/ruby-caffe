require 'rake/extensiontask'
require 'rspec/core/rake_task'

Rake::ExtensionTask.new :caffe do |ext|
  ext.lib_dir = 'lib/caffe'
  ext.source_pattern = '*.{hpp,cc}'
end

RSpec::Core::RakeTask.new :spec

task :test => [:compile, :spec]
