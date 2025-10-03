#ifndef ResponseDataOut_HPP
#define ResponseDataOut_HPP

#include "ResponseDataOut.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    void ResponseDataOut_destroy(ResponseDataOut* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::ResponseDataOut* ResponseDataOut::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::ResponseDataOut*>(this);
}

inline diplomat::capi::ResponseDataOut* ResponseDataOut::AsFFI() {
    return reinterpret_cast<diplomat::capi::ResponseDataOut*>(this);
}

inline const ResponseDataOut* ResponseDataOut::FromFFI(const diplomat::capi::ResponseDataOut* ptr) {
    return reinterpret_cast<const ResponseDataOut*>(ptr);
}

inline ResponseDataOut* ResponseDataOut::FromFFI(diplomat::capi::ResponseDataOut* ptr) {
    return reinterpret_cast<ResponseDataOut*>(ptr);
}

inline void ResponseDataOut::operator delete(void* ptr) {
    diplomat::capi::ResponseDataOut_destroy(reinterpret_cast<diplomat::capi::ResponseDataOut*>(ptr));
}


#endif // ResponseDataOut_HPP
