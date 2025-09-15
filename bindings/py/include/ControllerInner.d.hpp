#ifndef ControllerInner_D_HPP
#define ControllerInner_D_HPP

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
    struct ControllerInner;
} // namespace capi
} // namespace

class ControllerInner {
public:

  inline const diplomat::capi::ControllerInner* AsFFI() const;
  inline diplomat::capi::ControllerInner* AsFFI();
  inline static const ControllerInner* FromFFI(const diplomat::capi::ControllerInner* ptr);
  inline static ControllerInner* FromFFI(diplomat::capi::ControllerInner* ptr);
  inline static void operator delete(void* ptr);
private:
  ControllerInner() = delete;
  ControllerInner(const ControllerInner&) = delete;
  ControllerInner(ControllerInner&&) noexcept = delete;
  ControllerInner operator=(const ControllerInner&) = delete;
  ControllerInner operator=(ControllerInner&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // ControllerInner_D_HPP
