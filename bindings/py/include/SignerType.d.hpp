#ifndef SignerType_D_HPP
#define SignerType_D_HPP

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
    enum SignerType {
      SignerType_Starknet = 0,
      SignerType_StarknetAccount = 1,
      SignerType_Eip191 = 2,
      SignerType_Webauthn = 3,
      SignerType_Siws = 4,
      SignerType_Secp256k1 = 5,
      SignerType_Secp256r1 = 6,
    };

    typedef struct SignerType_option {union { SignerType ok; }; bool is_ok; } SignerType_option;
} // namespace capi
} // namespace

class SignerType {
public:
  enum Value {
    Starknet = 0,
    StarknetAccount = 1,
    Eip191 = 2,
    Webauthn = 3,
    Siws = 4,
    Secp256k1 = 5,
    Secp256r1 = 6,
  };

  SignerType(): value(Value::Starknet) {}

  // Implicit conversions between enum and ::Value
  constexpr SignerType(Value v) : value(v) {}
  constexpr operator Value() const { return value; }
  // Prevent usage as boolean value
  explicit operator bool() const = delete;

  inline diplomat::capi::SignerType AsFFI() const;
  inline static SignerType FromFFI(diplomat::capi::SignerType c_enum);
private:
    Value value;
};


#endif // SignerType_D_HPP
