#ifndef __UTIL
#define __UTIL

#include <rice/Data_Type.hpp>

template<typename T>
struct EmptyFreeFunction {
    static void free(T *obj) {}
};

template<typename T>
Rice::Data_Object<T> objectNoGC(T *obj) {
    return Rice::Data_Object<T>(obj, Rice::Data_Type<T>::klass(),
                                Rice::Default_Mark_Function<T>::mark,
                                EmptyFreeFunction<T>::free);
}

#endif
