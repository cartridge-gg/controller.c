#ifndef ControllerWithRuntime_HPP
#define ControllerWithRuntime_HPP

#include "ControllerWithRuntime.d.hpp"

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

    void ControllerWithRuntime_destroy(ControllerWithRuntime* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::ControllerWithRuntime* ControllerWithRuntime::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::ControllerWithRuntime*>(this);
}

inline diplomat::capi::ControllerWithRuntime* ControllerWithRuntime::AsFFI() {
  return reinterpret_cast<diplomat::capi::ControllerWithRuntime*>(this);
}

inline const ControllerWithRuntime* ControllerWithRuntime::FromFFI(const diplomat::capi::ControllerWithRuntime* ptr) {
  return reinterpret_cast<const ControllerWithRuntime*>(ptr);
}

inline ControllerWithRuntime* ControllerWithRuntime::FromFFI(diplomat::capi::ControllerWithRuntime* ptr) {
  return reinterpret_cast<ControllerWithRuntime*>(ptr);
}

inline void ControllerWithRuntime::operator delete(void* ptr) {
  diplomat::capi::ControllerWithRuntime_destroy(reinterpret_cast<diplomat::capi::ControllerWithRuntime*>(ptr));
}


#endif // ControllerWithRuntime_HPP
