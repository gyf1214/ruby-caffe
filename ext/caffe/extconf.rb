require 'require_all'
require_rel './mkmf-cxx'

@libdir_basename = 'lib'

dir_config 'caffe'
dir_config 'blas'

checking_for 'caffe.pc' do
  pkg_config 'caffe'
end

$libs = ''

$defs.push '-DCPU_ONLY' unless enable_config 'gpu', true

blas_header = 'cblas.h'

if enable_config 'mkl', false
  blas_header = 'mkl.h'
  $defs.push '-DUSE_MKL'
end

unless have_header blas_header
  puts 'blas header not found.'
  puts 'use build flag "--with-blas-dir=/path/to/blas" to specify the blas path.'
  puts 'or use "--with-blas-include" to specify the include path.'
  puts 'if you are using Intel MKL, use flag "--enable-mkl".'
  raise
end

unless have_library_empty('caffe') && have_header_cxx('caffe/caffe.hpp')
  puts 'caffe not found.'
  puts 'use build flag "--with-caffe-dir=/path/to/caffe" to specify the caffe path.'
  puts 'or use "--with-caffe-include" & "--with-caffe-lib" to specify include path & lib path separately.'
  raise
end

create_makefile 'caffe'
