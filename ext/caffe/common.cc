#include "common.hpp"
#include <rice/Module.hpp>
#include <rice/Class.hpp>
#include <caffe/caffe.hpp>

using namespace Rice;

#define EnumCast(type, classname) template<> \
type from_ruby<type>(Object self) { \
    int num = from_ruby<int>(self.call("to_i")); \
    return type(num); \
} \
template<> \
Object to_ruby<type>(const type &self) { \
    int num = int(self); \
    Object cl = (classname); \
    return cl.call("fetch", num); \
}

EnumCast(caffe::Phase, define_module("Caffe")
                      .const_get("Phase"));
EnumCast(caffe::Caffe::Brew, Class(define_module("Caffe")
                            .const_get("SolverParameter"))
                            .const_get("SolverMode"));

void Init_common() {
    Module rb_mCaffe = define_module("Caffe")
        .define_module_function("mode", caffe::Caffe::mode)
        .define_module_function("mode=", caffe::Caffe::set_mode)
        .define_module_function("solver_count", caffe::Caffe::solver_count)
        .define_module_function("solver_count=", caffe::Caffe::set_solver_count)
        .define_module_function("solver_rank", caffe::Caffe::solver_rank)
        .define_module_function("solver_rank=", caffe::Caffe::set_solver_rank)
        .define_module_function("multiprocess", caffe::Caffe::multiprocess)
        .define_module_function("multiprocess=", caffe::Caffe::set_multiprocess);
}
