require 'tempfile'
require 'protobuf'
require 'protobuf/descriptors'
require 'protobuf/code_generator'

ENV['PB_NO_TAG_WARNINGS'] = '1'

caffe ||= ENV['CAFFE']
caffe ||= '.'

path = File.expand_path 'proto', caffe
proto = File.expand_path 'caffe.proto', path
out = File.expand_path '../../lib/caffe', __FILE__

tmp = Tempfile.new 'caffe-proto'
begin
  cmd = "protoc -I#{path} -o #{tmp.path} #{proto}"
  raise unless system cmd
  set = Google::Protobuf::FileDescriptorSet.decode(tmp.read)
ensure
  tmp.close
  tmp.unlink
end

set.file.each do |file|
  res = Protobuf::Generators::FileGenerator.new(file).generate_output_file
  File.write File.expand_path(res.name, out), res.content
end
