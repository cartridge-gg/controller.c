#ifndef Version_D_HPP
#define Version_D_HPP

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
    enum Version {
      Version_V1_0_4 = 0,
      Version_V1_0_5 = 1,
      Version_V1_0_6 = 2,
      Version_V1_0_7 = 3,
      Version_V1_0_8 = 4,
      Version_V1_0_9 = 5,
      Version_LATEST = 6,
    };

    typedef struct Version_option {union { Version ok; }; bool is_ok; } Version_option;
} // namespace capi
} // namespace

class Version {
public:
  enum Value {
    V1_0_4 = 0,
    V1_0_5 = 1,
    V1_0_6 = 2,
    V1_0_7 = 3,
    V1_0_8 = 4,
    V1_0_9 = 5,
    LATEST = 6,
  };

  Version(): value(Value::V1_0_4) {}

  // Implicit conversions between enum and ::Value
  constexpr Version(Value v) : value(v) {}
  constexpr operator Value() const { return value; }
  // Prevent usage as boolean value
  explicit operator bool() const = delete;

  inline diplomat::capi::Version AsFFI() const;
  inline static Version FromFFI(diplomat::capi::Version c_enum);
private:
    Value value;
};


#endif // Version_D_HPP
