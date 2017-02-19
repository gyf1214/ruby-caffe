RSpec.describe Caffe::Net do
  before :example do
    Caffe.mode = Caffe::CPU
    @path = File.expand_path '../net/test.prototxt', __FILE__
  end

  shared_examples :net do
    before :example do
      @net = Caffe::Net.new @path, @phase
    end

    it 'can get the input' do
      expect(@net.inputs).to be_an(Array)
      expect([1, 2]).to include(@net.inputs.size)
      input = @net.inputs[0]
      expect(input).to be_a(Caffe::Blob)
      expect(input.shape).to eq([1, 32])
      if @net.inputs.size == 2
        input = @net.inputs[1]
        expect(input).to be_a(Caffe::Blob)
        expect(input.shape).to eq([1, 1])
      end
    end

    it 'can get blob by name' do
      blob = @net.blob('ip1')
      expect(blob).to be_a(Caffe::Blob)
      expect(blob.shape).to eq([1, 100])

      blob = @net.blob('ip2')
      expect(blob.shape).to eq([1, 2])
    end

    it 'can get output' do
      expect(@net.outputs).to be_an(Array)
      expect(@net.outputs.size).to eq(1)
      output = @net.outputs[0]
      expect(output).to be_a(Caffe::Blob)
      expect([[1, 2], []]).to include(output.shape)
    end

    it 'can reshape according to the input size' do
      @net.inputs.each do |input|
        shape = input.shape
        shape[0] = 64
        input.shape = shape
      end
      @net.reshape!
      expect(@net.blob('ip2').shape).to eq([64, 2])
    end

    def input_data
      data = Array.new 32 do
        Random.rand 2
      end
      @net.inputs[0].copy_from! data

      num = data.inject(0) do |i, x|
        2 * i + x
      end
      num % 1024 > 1024 / 2 ? 1 : 0
    end
  end

  shared_examples :trained do
    before :example do
      path = File.expand_path '../net/test.caffemodel', __FILE__
      @net.load_trained! path
    end

    it 'can read from trained model' do
      input = @net.inputs[0]
      expect(input.shape).to eq([1, 32])
    end
  end

  shared_examples :shared_net do
    before :example do
      @src = @net
      @net = Caffe::Net.new @path, Caffe::TEST
      @net.share_trained! @src
    end

    it 'can forward and return the same result' do
      input_data
      @src.inputs[0].copy_from! @net.inputs[0].to_a
      expect(@net.forward!).to eq(0.0)
      @src.forward!

      expect(@net.blob('ip1').to_a).to eq(@src.blob('ip1').to_a)
      expect(@net.blob('ip2').to_a).to eq(@src.blob('ip2').to_a)
    end
  end

  context 'test net' do
    before :example do
      @phase = Caffe::TEST
    end
    include_examples :net

    context 'shared with another' do
      include_examples :shared_net
    end

    context 'trained' do
      include_examples :trained

      context 'share with another' do
        include_examples :shared_net
      end

      it 'can forward' do
        expected = input_data

        expect(@net.forward!).to eq(0.0)
        output = @net.outputs[0]
        expect(output[0][0] + output[0][1]).to be_within(1e-6).of(1.0)

        label = output[0][1] > output[0][0] ? 1 : 0
        expect(label).to eq(expected)
      end

      it 'can forward then backward' do
        expect(@net.forward_backward!).to eq(0.0)
      end
    end
  end

  context 'train net' do
    before :example do
      @mode = Caffe::TRAIN
    end
    include_examples :net

    context 'share with another' do
      include_examples :shared_net
    end

    context 'trained' do
      include_examples :trained

      context 'share with another' do
        include_examples :shared_net
      end

      it 'can forward' do
        expected = input_data
        @net.inputs[1][0][0] = expected

        loss = @net.forward!
        expect(loss).not_to eq(0.0)
        expect(loss).to be_within(1e-2).of(0.0)
      end

      it 'can forward then backward' do
        ip2 = @net.blob 'ip2'
        expect(ip2.diff[0][0]).to eq(0.0)
        expect(ip2.diff[0][1]).to eq(0.0)

        loss = @net.forward_backward!
        expect(loss).not_to eq(0.0)
        expect(loss).to be_within(1e-2).of(0.0)

        expect(ip2.diff[0][0]).not_to eq(0.0)
        expect(ip2.diff[0][1]).not_to eq(0.0)
      end
    end
  end
end
