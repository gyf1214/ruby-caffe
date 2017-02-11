require 'require_all'
require_rel '../lib/caffe.rb'

RSpec.describe Caffe::Blob do
  before :example do
    @blob = Caffe::Blob.new 1, 2, 3, 4
  end

  it 'returns its shape as an array' do
    expect(@blob.shape).to eq([1, 2, 3, 4])
  end

  def getRandomIndices
    @blob.shape.map do |x|
      Random.rand x
    end
  end

  shared_examples :memory do
    it 'can access to next dimension via []' do
      indices = getRandomIndices
      3.times do |i|
        @data = @data[indices[i]]
        expect(@data).to be_a(Caffe::Blob::Cursor)
      end
    end

    it 'can be read via []' do
      i, j, k, l = getRandomIndices
      expect(@data[i][j][k][l]).to eq(0.0)
    end

    it 'can be write via []=' do
      i, j, k, l = getRandomIndices
      @data[i][j][k][l] = 1.0
      expect(@data[i][j][k][l]).to eq(1.0)
    end

    it 'returns the size of its memory' do
      i, j = getRandomIndices
      expect(@data.size).to eq(1 * 2 * 3 * 4)
      expect(@data[i][j].size).to eq(3 * 4)
    end

    it 'raise error when the index is out of range' do
      expect { @data[10] }.to raise_error(RangeError)
      expect { @data[0][0][0][10] }.to raise_error(RangeError)
    end

    it 'can be enumerated' do
      i, j, k, l = getRandomIndices

      @data[i].each do |x|
        expect(x).to be(0.0)
      end

      arr = Array.new @data[i][j].size, 0.0
      expect(@data[i][j].to_a).to eq(arr)
    end

    it 'can be copied from Array' do
      arr = Array.new @data.size do
        Random.rand 2
      end
      @data.copy arr
      expect(@data.to_a).to eq(arr)
    end
  end

  context '#data' do
    before :example do
      @data = @blob.data
    end

    include_examples :memory
  end

  context '#diff' do
    before :example do
      @data = @blob.diff
    end

    include_examples :memory
  end

  context 'itself' do
    before :example do
      @data = @blob
    end

    include_examples :memory
  end
end
