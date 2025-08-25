#ifndef Eip191Signer_HPP
#define Eip191Signer_HPP

#include "Eip191Signer.d.hpp"

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

    void Eip191Signer_destroy(Eip191Signer* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::Eip191Signer* Eip191Signer::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::Eip191Signer*>(this);
}

inline diplomat::capi::Eip191Signer* Eip191Signer::AsFFI() {
  return reinterpret_cast<diplomat::capi::Eip191Signer*>(this);
}

inline const Eip191Signer* Eip191Signer::FromFFI(const diplomat::capi::Eip191Signer* ptr) {
  return reinterpret_cast<const Eip191Signer*>(ptr);
}

inline Eip191Signer* Eip191Signer::FromFFI(diplomat::capi::Eip191Signer* ptr) {
  return reinterpret_cast<Eip191Signer*>(ptr);
}

inline void Eip191Signer::operator delete(void* ptr) {
  diplomat::capi::Eip191Signer_destroy(reinterpret_cast<diplomat::capi::Eip191Signer*>(ptr));
}


#endif // Eip191Signer_HPP
