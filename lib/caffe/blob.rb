module Caffe
  # Wrapper class for caffe::Blob<float>
  class Blob
    # Proxy class to access caffe::Blob<float> like Array / Enumerable
    class Cursor
      include Enumerable

      alias count size
    end

    def [](index)
      data[index]
    end

    def []=(index, x)
      data[index] = x
    end

    def size
      data.size
    end

    def copy_from!(x)
      data.copy_from! x
    end

    def each(&blk)
      data.each(&blk)
    end

    include Enumerable

    alias count size
  end
end
