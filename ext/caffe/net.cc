#include "net.hpp"
#include "blob.hpp"
#include "util.hpp"
#include <rice/Data_Type.hpp>
#include <rice/Constructor.hpp>
#include <rice/Module.hpp>
#include <rice/String.hpp>
#include <rice/Array.hpp>

using namespace Rice;

static Array getInputs(Object self) {
    Net *net = from_ruby<Net *>(self);
    const std::vector<Blob *> &vec = net -> input_blobs();
    Array ret;
    int n = vec.size();
    for (int i = 0; i < n; ++i) {
        ret.push(objectNoGC(vec[i]));
    }
    return ret;
}

static Object getBlobByName(Object self, String name) {
    Net *net = from_ruby<Net *>(self);
    Blob *blob = net -> blob_by_name(from_ruby<std::string>(name)).get();

    if (blob) {
        return objectNoGC(blob);
    } else {
        return Qnil;
    }
}

void Init_net() {
    Module rb_mCaffe = define_module("Caffe");

    Data_Type<caffe::Phase> rb_cPhase = rb_mCaffe
        .define_class<caffe::Phase>("Phase");
    rb_mCaffe.const_set("TRAIN", to_ruby(caffe::TRAIN))
             .const_set("TEST", to_ruby(caffe::TEST));

    Data_Type<Net> rb_cNet = rb_mCaffe
        .define_class<Net>("Net")
        .define_constructor(Constructor<Net, std::string, caffe::Phase>())
        .define_method("inputs", &getInputs)
        .define_method("blob", &getBlobByName);
}
