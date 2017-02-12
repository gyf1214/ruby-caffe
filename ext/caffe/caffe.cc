#include <caffe/caffe.hpp>
#include "blob.hpp"
#include "net.hpp"

extern "C"
void Init_caffe() {
    ::google::InitGoogleLogging("ruby-caffe");

    Init_blob();
    Init_net();
}
