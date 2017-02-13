require 'require_all'
require_rel '../lib/caffe.rb'

RSpec.describe Caffe::Net do
  before :example do
    path = File.expand_path '../test.prototxt', __FILE__
    @net = Caffe::Net.new path, Caffe::TEST
  end

  it 'can get the input' do
    expect(@net.inputs).to be_an(Array)
    expect(@net.inputs.size).to eq(1)
    input = @net.inputs[0]
    expect(input).to be_a(Caffe::Blob)
    expect(input.shape).to eq([1, 10])
  end

  it 'can get blob by name' do
    blob = @net.blob('ip1')
    expect(blob).to be_a(Caffe::Blob)
    expect(blob.shape).to eq([1, 100])

    blob = @net.blob('prob')
    expect(blob.shape).to eq([1, 2])
  end

  it 'can get output' do
    expect(@net.outputs).to be_an(Array)
    expect(@net.outputs.size).to eq(1)
    output = @net.outputs[0]
    expect(output).to be_a(Caffe::Blob)
    expect(output.shape).to eq([1, 2])
  end

  it 'can reshape according to the input size' do
    input = @net.inputs[0]
    input.shape = [64, 10]
    @net.reshape
    expect(@net.outputs[0].shape).to eq([64, 2])
  end
end
