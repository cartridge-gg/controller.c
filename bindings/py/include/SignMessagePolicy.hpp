#ifndef SignMessagePolicy_HPP
#define SignMessagePolicy_HPP

#include "SignMessagePolicy.d.hpp"

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

    void SignMessagePolicy_destroy(SignMessagePolicy* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::SignMessagePolicy* SignMessagePolicy::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::SignMessagePolicy*>(this);
}

inline diplomat::capi::SignMessagePolicy* SignMessagePolicy::AsFFI() {
    return reinterpret_cast<diplomat::capi::SignMessagePolicy*>(this);
}

inline const SignMessagePolicy* SignMessagePolicy::FromFFI(const diplomat::capi::SignMessagePolicy* ptr) {
    return reinterpret_cast<const SignMessagePolicy*>(ptr);
}

inline SignMessagePolicy* SignMessagePolicy::FromFFI(diplomat::capi::SignMessagePolicy* ptr) {
    return reinterpret_cast<SignMessagePolicy*>(ptr);
}

inline void SignMessagePolicy::operator delete(void* ptr) {
    diplomat::capi::SignMessagePolicy_destroy(reinterpret_cast<diplomat::capi::SignMessagePolicy*>(ptr));
}


#endif // SignMessagePolicy_HPP
