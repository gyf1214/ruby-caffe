#include <rice/Class.hpp>
#include <caffe/caffe.hpp>
#include "blob.hpp"
#include "net.hpp"

extern "C"
void Init_caffe() {
    Init_blob();
    Init_net();
}
