require 'mkmf-rice'

if pkg_config 'caffe'
  $libs << ' '
else
  dir_config 'caffe'
  unless have_library 'caffe'
    raise 'caffe lib not found!'
  end
end

create_makefile 'caffe'
