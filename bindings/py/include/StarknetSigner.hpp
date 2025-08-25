#ifndef StarknetSigner_HPP
#define StarknetSigner_HPP

#include "StarknetSigner.d.hpp"

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

    void StarknetSigner_destroy(StarknetSigner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::StarknetSigner* StarknetSigner::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::StarknetSigner*>(this);
}

inline diplomat::capi::StarknetSigner* StarknetSigner::AsFFI() {
  return reinterpret_cast<diplomat::capi::StarknetSigner*>(this);
}

inline const StarknetSigner* StarknetSigner::FromFFI(const diplomat::capi::StarknetSigner* ptr) {
  return reinterpret_cast<const StarknetSigner*>(ptr);
}

inline StarknetSigner* StarknetSigner::FromFFI(diplomat::capi::StarknetSigner* ptr) {
  return reinterpret_cast<StarknetSigner*>(ptr);
}

inline void StarknetSigner::operator delete(void* ptr) {
  diplomat::capi::StarknetSigner_destroy(reinterpret_cast<diplomat::capi::StarknetSigner*>(ptr));
}


#endif // StarknetSigner_HPP
