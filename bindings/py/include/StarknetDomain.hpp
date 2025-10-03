#ifndef StarknetDomain_HPP
#define StarknetDomain_HPP

#include "StarknetDomain.d.hpp"

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

    void StarknetDomain_destroy(StarknetDomain* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::StarknetDomain* StarknetDomain::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::StarknetDomain*>(this);
}

inline diplomat::capi::StarknetDomain* StarknetDomain::AsFFI() {
    return reinterpret_cast<diplomat::capi::StarknetDomain*>(this);
}

inline const StarknetDomain* StarknetDomain::FromFFI(const diplomat::capi::StarknetDomain* ptr) {
    return reinterpret_cast<const StarknetDomain*>(ptr);
}

inline StarknetDomain* StarknetDomain::FromFFI(diplomat::capi::StarknetDomain* ptr) {
    return reinterpret_cast<StarknetDomain*>(ptr);
}

inline void StarknetDomain::operator delete(void* ptr) {
    diplomat::capi::StarknetDomain_destroy(reinterpret_cast<diplomat::capi::StarknetDomain*>(ptr));
}


#endif // StarknetDomain_HPP
