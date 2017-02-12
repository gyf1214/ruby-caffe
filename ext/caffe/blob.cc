#include "blob.hpp"
#include <rice/Data_Type.hpp>
#include <rice/Constructor.hpp>
#include <rice/Module.hpp>
#include <stdexcept>
#include <algorithm>

using namespace Rice;

BlobCursor::BlobCursor(Object blob, bool diff) : diff(diff) {
    ref = from_ruby<Blob *>(blob);
}

void BlobCursor::checkValid() const {
    int n = indices.size();
    const std::vector<int> &shape = ref -> shape();
    if (n > shape.size()) throw std::logic_error("Invalid BlobCursor!");
    for (int i = 0; i < n; ++i) {
        if (shape[i] <= indices[i]) {
            throw std::out_of_range("Index out of range!");
        }
    }
}

BlobCursor BlobCursor::next(int index) const {
    BlobCursor ret = *this;
    ret.indices.push_back(index);
    ret.checkValid();
    return ret;
}

Object BlobCursor::get(int index) const {
    BlobCursor next = this -> next(index);
    if (next.indices.size() == ref -> shape().size()) {
        return to_ruby(*next.begin());
    } else {
        return to_ruby(next);
    }
}

Object BlobCursor::set(int index, Object data) {
    BlobCursor next = this -> next(index);
    if (next.indices.size() == ref -> shape().size()) {
        *next.mbegin() = from_ruby<float>(data);
        return data;
    } else {
        throw std::logic_error("Not implemented!");
    }
}

const float *BlobCursor::begin() {
    std::vector<int> full = indices;
    full.resize(ref -> shape().size());
    const float *base = diff ? ref -> cpu_diff() : ref -> cpu_data();

    return base + ref -> offset(full);
}

const float *BlobCursor::end() {
    return begin() + count();
}

float *BlobCursor::mbegin() {
    std::vector<int> full = indices;
    full.resize(ref -> shape().size());
    float *base = diff ? ref -> mutable_cpu_diff() : ref -> mutable_cpu_data();

    return base + ref -> offset(full);
}

float *BlobCursor::mend() {
    return mbegin() + count();
}

int BlobCursor::count() const {
    const std::vector<int> &shape = ref -> shape();
    int n = shape.size();
    int ans = 1;
    for (int k = indices.size(); k < n; ++k) {
        ans *= shape[k];
    }
    return ans;
}

int BlobCursor::copy(Array data) {
    int n = std::min(int(data.size()), count());
    float *base = mbegin();
    for (int i = 0; i < n; ++i) {
        base[i] = from_ruby<float>(data[i]);
    }
    return n;
}

static Object getBlobData(Object self) {
    return to_ruby(BlobCursor(self));
}

static Object getBlobDiff(Object self) {
    return to_ruby(BlobCursor(self, true));
}

static Array getBlobShape(Object self) {
    const std::vector<int> &shape = from_ruby<Blob *>(self) -> shape();
    return Array(shape.begin(), shape.end());
}

struct BlobConstructor {
    static void construct(Object self, Array shape) {
        int n = shape.size();
        if (n > 4) {
            throw std::invalid_argument("Shape dimension exceeds 4!");
        }
        std::vector<int> vec(n);
        for (int i = 0; i < n; ++i) {
            vec[i] = from_ruby<int>(shape[i]);
        }
        DATA_PTR(self.value()) = new Blob(vec);
    }
};

void Init_blob() {
    Module rb_mCaffe = define_module("Caffe");

    Data_Type<Blob> rb_cBlob = rb_mCaffe
        .define_class<Blob>("Blob")
        .define_constructor(BlobConstructor())
        .define_method("data", getBlobData)
        .define_method("diff", getBlobDiff)
        .define_method("shape", getBlobShape);

    Data_Type<BlobCursor> rb_cCursor = rb_cBlob
        .define_class<BlobCursor>("Cursor")
        .define_constructor(Constructor<BlobCursor, Object, bool>())
        .define_method("[]", &BlobCursor::get)
        .define_method("[]=", &BlobCursor::set)
        .define_method("size", &BlobCursor::count)
        .define_iterator(&BlobCursor::begin, &BlobCursor::end)
        .define_method("copy", &BlobCursor::copy);
}
