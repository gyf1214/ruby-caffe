require 'require_all'

module Caffe
  VERSION = '0.1.0'
end

require_rel './caffe/caffe.pb.rb'
require_rel './caffe/*'
