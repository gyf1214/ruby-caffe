#include "common.hpp"
#include <rice/Module.hpp>
#include <rice/Data_Type.hpp>
#include <rice/Enum.hpp>
#include <caffe/caffe.hpp>

using namespace Rice;

void Init_common() {
    Module rb_mCaffe = define_module("Caffe");

    Data_Type<caffe::Phase> rb_ePhase =
         define_enum<caffe::Phase>("Phase", rb_mCaffe)
        .define_value("TRAIN", caffe::TRAIN)
        .define_value("TEST", caffe::TEST);

    rb_mCaffe.const_set("TRAIN", rb_ePhase.const_get("TRAIN"))
             .const_set("TEST", rb_ePhase.const_get("TEST"));
}
