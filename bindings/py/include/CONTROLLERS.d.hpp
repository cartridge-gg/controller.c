#ifndef CONTROLLERS_D_HPP
#define CONTROLLERS_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct ControllerError; }
class ControllerError;
class Version;


namespace diplomat {
namespace capi {
    struct CONTROLLERS;
} // namespace capi
} // namespace

class CONTROLLERS {
public:

  inline static diplomat::result<std::string, std::unique_ptr<ControllerError>> get_class_hash(Version version);
  template<typename W>
  inline static diplomat::result<std::monostate, std::unique_ptr<ControllerError>> get_class_hash_write(Version version, W& writeable_output);

  inline const diplomat::capi::CONTROLLERS* AsFFI() const;
  inline diplomat::capi::CONTROLLERS* AsFFI();
  inline static const CONTROLLERS* FromFFI(const diplomat::capi::CONTROLLERS* ptr);
  inline static CONTROLLERS* FromFFI(diplomat::capi::CONTROLLERS* ptr);
  inline static void operator delete(void* ptr);
private:
  CONTROLLERS() = delete;
  CONTROLLERS(const CONTROLLERS&) = delete;
  CONTROLLERS(CONTROLLERS&&) noexcept = delete;
  CONTROLLERS operator=(const CONTROLLERS&) = delete;
  CONTROLLERS operator=(CONTROLLERS&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // CONTROLLERS_D_HPP
