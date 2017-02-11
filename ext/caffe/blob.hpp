#ifndef __BLOB
#define __BLOB

#include <rice/Class.hpp>
#include <rice/Array.hpp>
#include <caffe/caffe.hpp>
#include <vector>
#include <stdexcept>

typedef caffe::Blob<float> Blob;

class BlobCursor {
    std::vector<int> indices;
    Blob *ref;
    bool diff;
    void checkValid(void) const;
public:
    BlobCursor(Rice::Object blob, bool diff = false);
    BlobCursor next(int index) const;
    Rice::Object get(int index) const;
    Rice::Object set(int index, Rice::Object data);
    const float *begin(void);
    const float *end(void);
    float *mbegin(void);
    float *mend(void);
    int count(void) const;
    int copy(Rice::Array data);
};

void Init_blob(void);

#endif
