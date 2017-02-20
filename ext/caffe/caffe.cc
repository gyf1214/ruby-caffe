#include <caffe/caffe.hpp>
#include "common.hpp"
#include "blob.hpp"
#include "net.hpp"
#include "solver.hpp"

extern "C"
void Init_caffe() {
    ::google::InitGoogleLogging("ruby-caffe");

    Init_common();
    Init_blob();
    Init_net();
    Init_solver();
}
