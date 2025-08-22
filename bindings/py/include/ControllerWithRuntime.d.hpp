#ifndef ControllerWithRuntime_D_HPP
#define ControllerWithRuntime_D_HPP

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
    struct ControllerWithRuntime;
} // namespace capi
} // namespace

/**
 * Controller wrapper with its own runtime
 */
class ControllerWithRuntime {
public:

  inline const diplomat::capi::ControllerWithRuntime* AsFFI() const;
  inline diplomat::capi::ControllerWithRuntime* AsFFI();
  inline static const ControllerWithRuntime* FromFFI(const diplomat::capi::ControllerWithRuntime* ptr);
  inline static ControllerWithRuntime* FromFFI(diplomat::capi::ControllerWithRuntime* ptr);
  inline static void operator delete(void* ptr);
private:
  ControllerWithRuntime() = delete;
  ControllerWithRuntime(const ControllerWithRuntime&) = delete;
  ControllerWithRuntime(ControllerWithRuntime&&) noexcept = delete;
  ControllerWithRuntime operator=(const ControllerWithRuntime&) = delete;
  ControllerWithRuntime operator=(ControllerWithRuntime&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // ControllerWithRuntime_D_HPP
