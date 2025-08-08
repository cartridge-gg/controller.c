#ifndef OwnerType_D_HPP
#define OwnerType_D_HPP

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
    enum OwnerType {
      OwnerType_Signer = 0,
      OwnerType_Account = 1,
    };

    typedef struct OwnerType_option {union { OwnerType ok; }; bool is_ok; } OwnerType_option;
} // namespace capi
} // namespace

class OwnerType {
public:
  enum Value {
    Signer = 0,
    Account = 1,
  };

  OwnerType(): value(Value::Signer) {}

  // Implicit conversions between enum and ::Value
  constexpr OwnerType(Value v) : value(v) {}
  constexpr operator Value() const { return value; }
  // Prevent usage as boolean value
  explicit operator bool() const = delete;

  inline diplomat::capi::OwnerType AsFFI() const;
  inline static OwnerType FromFFI(diplomat::capi::OwnerType c_enum);
private:
    Value value;
};


#endif // OwnerType_D_HPP
