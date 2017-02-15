#ifndef __COMMON
#define __COMMON

#include <caffe/caffe.hpp>
#include <rice/Data_Type.hpp>

#define DefineEnumCast(type) template<> \
type from_ruby<type>(Rice::Object); \
template<> \
Rice::Object to_ruby<type>(const type &)

DefineEnumCast(caffe::Phase);
DefineEnumCast(caffe::Caffe::Brew);

void Init_common(void);

#endif
