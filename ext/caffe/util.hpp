#ifndef __UTIL
#define __UTIL

#include <rice/Data_Type.hpp>
#include <rice/Array.hpp>

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

template<typename Iter, typename Func>
Rice::Array mapArray(Iter begin, Iter end, Func func) {
    Rice::Array ret;
    for (; begin != end; ++begin) {
        ret.push(to_ruby(func(*begin)));
    }
    return ret;
}

#endif
