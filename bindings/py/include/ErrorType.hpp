#ifndef ErrorType_HPP
#define ErrorType_HPP

#include "ErrorType.d.hpp"

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

inline diplomat::capi::ErrorType ErrorType::AsFFI() const {
  return static_cast<diplomat::capi::ErrorType>(value);
}

inline ErrorType ErrorType::FromFFI(diplomat::capi::ErrorType c_enum) {
  switch (c_enum) {
    case diplomat::capi::ErrorType_InitError:
    case diplomat::capi::ErrorType_RuntimeError:
    case diplomat::capi::ErrorType_SessionError:
    case diplomat::capi::ErrorType_InvalidInput:
    case diplomat::capi::ErrorType_NotDeployed:
    case diplomat::capi::ErrorType_InsufficientBalance:
      return static_cast<ErrorType::Value>(c_enum);
    default:
      std::abort();
  }
}
#endif // ErrorType_HPP
