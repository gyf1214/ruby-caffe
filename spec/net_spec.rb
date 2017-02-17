RSpec.describe Caffe::Net do
  before :example do
    Caffe.mode = Caffe::CPU
    path = File.expand_path '../net/test.prototxt', __FILE__
    @net = Caffe::Net.new path, Caffe::TEST
  end

  it 'can get the input' do
    expect(@net.inputs).to be_an(Array)
    expect(@net.inputs.size).to eq(1)
    input = @net.inputs[0]
    expect(input).to be_a(Caffe::Blob)
    expect(input.shape).to eq([1, 32])
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
    input.shape = [64, 32]
    @net.reshape!
    expect(@net.outputs[0].shape).to eq([64, 2])
  end

  context 'trained net' do
    before :example do
      path = File.expand_path '../net/test.caffemodel', __FILE__
      @net.load_trained! path
    end

    it 'can read from trained model' do
      input = @net.inputs[0]
      expect(input.shape).to eq([1, 32])
    end

    it 'can forward' do
      data = Array.new 32 do
        Random.rand 2
      end
      input = @net.inputs[0]
      input.copy_from! data

      expect(@net.forward!).to eq(0.0)
      output = @net.outputs[0]
      expect(output[0][0] + output[0][1]).to be_within(1e-6).of(1.0)

      label = output[0][1] > output[0][0] ? 1 : 0
      num = data.inject(0) do |i, x|
        2 * i + x
      end
      expected = num % 1024 > 1024 / 2 ? 1 : 0

      expect(label).to eq(expected)
    end
  end
end
