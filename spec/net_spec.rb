require 'require_all'
require_rel '../lib/caffe.rb'

RSpec.describe Caffe::Net do
  before :example do
    path = File.expand_path '../test.prototxt', __FILE__
    @net = Caffe::Net.new path, Caffe::TEST
  end

  it 'can gets the input' do
    expect(@net.inputs).to be_an(Array)
    expect(@net.inputs.size).to eq(1)
    input = @net.inputs[0]
    expect(input).to be_a(Caffe::Blob)
    expect(input.shape).to eq([1, 10])
  end

  it 'can get blob by name' do
    blob = @net.blob('ip')
    expect(blob).to be_a(Caffe::Blob)
    expect(blob.shape).to eq([1, 100])
  end
end
