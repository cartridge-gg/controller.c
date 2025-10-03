#ifndef TypedData_HPP
#define TypedData_HPP

#include "TypedData.d.hpp"

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

    void TypedData_destroy(TypedData* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::TypedData* TypedData::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::TypedData*>(this);
}

inline diplomat::capi::TypedData* TypedData::AsFFI() {
    return reinterpret_cast<diplomat::capi::TypedData*>(this);
}

inline const TypedData* TypedData::FromFFI(const diplomat::capi::TypedData* ptr) {
    return reinterpret_cast<const TypedData*>(ptr);
}

inline TypedData* TypedData::FromFFI(diplomat::capi::TypedData* ptr) {
    return reinterpret_cast<TypedData*>(ptr);
}

inline void TypedData::operator delete(void* ptr) {
    diplomat::capi::TypedData_destroy(reinterpret_cast<diplomat::capi::TypedData*>(ptr));
}


#endif // TypedData_HPP
