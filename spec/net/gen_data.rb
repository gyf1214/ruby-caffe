$LOAD_PATH << File.expand_path('../../../lib', __FILE__)

require 'lmdb'
require 'caffe'

def gen
  data = Array.new 32 do
    Random.rand 2
  end

  num = data.inject(0) do |i, x|
    i = 2 * i + x
  end

  label = (num % 1024 > 1024 / 2) ? 1 : 0

  datum = Caffe::Datum.new channels: 32, height: 1, width: 1, label: label
  datum.data = data.pack 'C*'

  datum.serialize_to_string
end

env = LMDB.new File.expand_path('../test_data', __FILE__)
env.mapsize = 1 * 1024 * 1024 * 1024
db = env.database

25600.times do |i|
  db['%08d' % i] = gen
end
