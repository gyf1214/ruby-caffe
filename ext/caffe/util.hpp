#ifndef __UTIL
#define __UTIL

#include <caffe/caffe.hpp>
#include <rice/Data_Type.hpp>
#include <rice/Array.hpp>
#include <vector>

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

template<typename T, typename U>
Rice::Data_Object<T> sharedToObj(U obj) {
    return objectNoGC(obj.get());
}

template<typename Iter, typename Func>
Rice::Array mapArray(Iter begin, Iter end, Func func) {
    Rice::Array ret;
    for (; begin != end; ++begin) {
        ret.push(to_ruby(func(*begin)));
    }
    return ret;
}

template<typename T>
std::vector<T> arrayToVector(Rice::Array arr) {
    int n = arr.size();
    std::vector<T> ret(n);
    for (int i = 0; i < n; ++i) {
        ret[i] = from_ruby<T>(arr[i]);
    }
    return ret;
}

#endif
