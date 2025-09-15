#ifndef ControllerInner_HPP
#define ControllerInner_HPP

#include "ControllerInner.d.hpp"

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

    void ControllerInner_destroy(ControllerInner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::ControllerInner* ControllerInner::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::ControllerInner*>(this);
}

inline diplomat::capi::ControllerInner* ControllerInner::AsFFI() {
  return reinterpret_cast<diplomat::capi::ControllerInner*>(this);
}

inline const ControllerInner* ControllerInner::FromFFI(const diplomat::capi::ControllerInner* ptr) {
  return reinterpret_cast<const ControllerInner*>(ptr);
}

inline ControllerInner* ControllerInner::FromFFI(diplomat::capi::ControllerInner* ptr) {
  return reinterpret_cast<ControllerInner*>(ptr);
}

inline void ControllerInner::operator delete(void* ptr) {
  diplomat::capi::ControllerInner_destroy(reinterpret_cast<diplomat::capi::ControllerInner*>(ptr));
}


#endif // ControllerInner_HPP
