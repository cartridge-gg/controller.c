#ifndef Version_HPP
#define Version_HPP

#include "Version.d.hpp"

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

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::capi::Version Version::AsFFI() const {
  return static_cast<diplomat::capi::Version>(value);
}

inline Version Version::FromFFI(diplomat::capi::Version c_enum) {
  switch (c_enum) {
    case diplomat::capi::Version_V1_0_4:
    case diplomat::capi::Version_V1_0_5:
    case diplomat::capi::Version_V1_0_6:
    case diplomat::capi::Version_V1_0_7:
    case diplomat::capi::Version_V1_0_8:
    case diplomat::capi::Version_V1_0_9:
    case diplomat::capi::Version_LATEST:
      return static_cast<Version::Value>(c_enum);
    default:
      std::abort();
  }
}
#endif // Version_HPP
