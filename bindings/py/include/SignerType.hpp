#ifndef SignerType_HPP
#define SignerType_HPP

#include "SignerType.d.hpp"

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

inline diplomat::capi::SignerType SignerType::AsFFI() const {
  return static_cast<diplomat::capi::SignerType>(value);
}

inline SignerType SignerType::FromFFI(diplomat::capi::SignerType c_enum) {
  switch (c_enum) {
    case diplomat::capi::SignerType_Starknet:
    case diplomat::capi::SignerType_StarknetAccount:
    case diplomat::capi::SignerType_Eip191:
    case diplomat::capi::SignerType_Webauthn:
    case diplomat::capi::SignerType_Siws:
    case diplomat::capi::SignerType_Secp256k1:
    case diplomat::capi::SignerType_Secp256r1:
      return static_cast<SignerType::Value>(c_enum);
    default:
      std::abort();
  }
}
#endif // SignerType_HPP
