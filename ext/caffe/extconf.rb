require File.expand_path '../mkmf_cxx', __FILE__

@libdir_basename = 'lib'

dir_config 'caffe'
dir_config 'blas'

checking_for 'caffe.pc' do
  pkg_config 'caffe'
end

$libs = ''

$defs.push '-DCPU_ONLY' unless enable_config 'gpu', true

mkl = enable_config 'mkl', nil

if mkl == true || !have_header('cblas.h')
  $defs.push '-DUSE_MKL'
  if mkl == false || !have_header('mkl.h')
    puts <<MSG
blas header not found.
use build flag "--with-blas-dir=/path/to/blas" to specify the blas path.
or use "--with-blas-include" to specify the include path.
MSG
    raise
  end
end

unless library?('caffe') && header_cxx?('caffe/caffe.hpp')
  puts <<MSG
caffe not found.
use build flag "--with-caffe-dir=/path/to/caffe" to specify the caffe path.
or use "--with-caffe-include" & "--with-caffe-lib" to specify include path & lib path separately.
MSG
  raise
end

create_makefile 'caffe'
