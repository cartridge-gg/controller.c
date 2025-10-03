#ifndef SessionAccountInner_HPP
#define SessionAccountInner_HPP

#include "SessionAccountInner.d.hpp"

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

    void SessionAccountInner_destroy(SessionAccountInner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::SessionAccountInner* SessionAccountInner::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::SessionAccountInner*>(this);
}

inline diplomat::capi::SessionAccountInner* SessionAccountInner::AsFFI() {
    return reinterpret_cast<diplomat::capi::SessionAccountInner*>(this);
}

inline const SessionAccountInner* SessionAccountInner::FromFFI(const diplomat::capi::SessionAccountInner* ptr) {
    return reinterpret_cast<const SessionAccountInner*>(ptr);
}

inline SessionAccountInner* SessionAccountInner::FromFFI(diplomat::capi::SessionAccountInner* ptr) {
    return reinterpret_cast<SessionAccountInner*>(ptr);
}

inline void SessionAccountInner::operator delete(void* ptr) {
    diplomat::capi::SessionAccountInner_destroy(reinterpret_cast<diplomat::capi::SessionAccountInner*>(ptr));
}


#endif // SessionAccountInner_HPP
