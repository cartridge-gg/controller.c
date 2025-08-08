#ifndef OwnerType_HPP
#define OwnerType_HPP

#include "OwnerType.d.hpp"

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

inline diplomat::capi::OwnerType OwnerType::AsFFI() const {
  return static_cast<diplomat::capi::OwnerType>(value);
}

inline OwnerType OwnerType::FromFFI(diplomat::capi::OwnerType c_enum) {
  switch (c_enum) {
    case diplomat::capi::OwnerType_Signer:
    case diplomat::capi::OwnerType_Account:
      return static_cast<OwnerType::Value>(c_enum);
    default:
      std::abort();
  }
}
#endif // OwnerType_HPP
