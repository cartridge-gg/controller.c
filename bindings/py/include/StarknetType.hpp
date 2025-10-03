#ifndef StarknetType_HPP
#define StarknetType_HPP

#include "StarknetType.d.hpp"

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

    void StarknetType_destroy(StarknetType* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::StarknetType* StarknetType::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::StarknetType*>(this);
}

inline diplomat::capi::StarknetType* StarknetType::AsFFI() {
    return reinterpret_cast<diplomat::capi::StarknetType*>(this);
}

inline const StarknetType* StarknetType::FromFFI(const diplomat::capi::StarknetType* ptr) {
    return reinterpret_cast<const StarknetType*>(ptr);
}

inline StarknetType* StarknetType::FromFFI(diplomat::capi::StarknetType* ptr) {
    return reinterpret_cast<StarknetType*>(ptr);
}

inline void StarknetType::operator delete(void* ptr) {
    diplomat::capi::StarknetType_destroy(reinterpret_cast<diplomat::capi::StarknetType*>(ptr));
}


#endif // StarknetType_HPP
