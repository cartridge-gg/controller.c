#ifndef ErrorType_D_HPP
#define ErrorType_D_HPP

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
    enum ErrorType {
      ErrorType_InitError = 0,
      ErrorType_RuntimeError = 1,
      ErrorType_SessionError = 2,
      ErrorType_InvalidInput = 3,
      ErrorType_NotDeployed = 4,
      ErrorType_InsufficientBalance = 5,
    };

    typedef struct ErrorType_option {union { ErrorType ok; }; bool is_ok; } ErrorType_option;
} // namespace capi
} // namespace

class ErrorType {
public:
  enum Value {
    InitError = 0,
    RuntimeError = 1,
    SessionError = 2,
    InvalidInput = 3,
    NotDeployed = 4,
    InsufficientBalance = 5,
  };

  ErrorType(): value(Value::InitError) {}

  // Implicit conversions between enum and ::Value
  constexpr ErrorType(Value v) : value(v) {}
  constexpr operator Value() const { return value; }
  // Prevent usage as boolean value
  explicit operator bool() const = delete;

  inline diplomat::capi::ErrorType AsFFI() const;
  inline static ErrorType FromFFI(diplomat::capi::ErrorType c_enum);
private:
    Value value;
};


#endif // ErrorType_D_HPP
