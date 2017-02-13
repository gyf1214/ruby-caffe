#include "common.hpp"
#include <rice/Module.hpp>
#include <rice/Data_Type.hpp>
#include <rice/Enum.hpp>
#include <caffe/caffe.hpp>

using namespace Rice;

void Init_common() {
    Module rb_mCaffe = define_module("Caffe");

    Enum<caffe::Phase> rb_ePhase =
         define_enum<caffe::Phase>("Phase", rb_mCaffe)
        .define_value("TRAIN", caffe::TRAIN)
        .define_value("TEST", caffe::TEST);

    Enum<caffe::Caffe::Brew> rb_eBrew =
         define_enum<caffe::Caffe::Brew>("Brew", rb_mCaffe)
        .define_value("CPU", caffe::Caffe::CPU)
        .define_value("GPU", caffe::Caffe::GPU);

    rb_mCaffe.const_set("TRAIN", to_ruby(caffe::TRAIN))
             .const_set("TEST", to_ruby(caffe::TEST))
             .const_set("CPU", to_ruby(caffe::Caffe::CPU))
             .const_set("GPU", to_ruby(caffe::Caffe::GPU))
             .define_module_function("mode", caffe::Caffe::mode)
             .define_module_function("mode=", caffe::Caffe::set_mode)
             .define_module_function("solver_count", caffe::Caffe::solver_count)
             .define_module_function("solver_count=", caffe::Caffe::set_solver_count)
             .define_module_function("solver_rank", caffe::Caffe::solver_rank)
             .define_module_function("solver_rank=", caffe::Caffe::set_solver_rank)
             .define_module_function("multiprocess", caffe::Caffe::multiprocess)
             .define_module_function("multiprocess=", caffe::Caffe::set_multiprocess);
}
