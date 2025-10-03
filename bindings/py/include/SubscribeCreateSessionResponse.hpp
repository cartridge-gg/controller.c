#ifndef SubscribeCreateSessionResponse_HPP
#define SubscribeCreateSessionResponse_HPP

#include "SubscribeCreateSessionResponse.d.hpp"

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

    void SubscribeCreateSessionResponse_destroy(SubscribeCreateSessionResponse* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::SubscribeCreateSessionResponse*>(this);
}

inline diplomat::capi::SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::AsFFI() {
    return reinterpret_cast<diplomat::capi::SubscribeCreateSessionResponse*>(this);
}

inline const SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::FromFFI(const diplomat::capi::SubscribeCreateSessionResponse* ptr) {
    return reinterpret_cast<const SubscribeCreateSessionResponse*>(ptr);
}

inline SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::FromFFI(diplomat::capi::SubscribeCreateSessionResponse* ptr) {
    return reinterpret_cast<SubscribeCreateSessionResponse*>(ptr);
}

inline void SubscribeCreateSessionResponse::operator delete(void* ptr) {
    diplomat::capi::SubscribeCreateSessionResponse_destroy(reinterpret_cast<diplomat::capi::SubscribeCreateSessionResponse*>(ptr));
}


#endif // SubscribeCreateSessionResponse_HPP
