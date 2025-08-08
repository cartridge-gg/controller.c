#ifndef DiplomatOwner_D_HPP
#define DiplomatOwner_D_HPP

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


namespace diplomat {
namespace capi {
    struct DiplomatOwner;
} // namespace capi
} // namespace

/**
 * Opaque wrapper for Owner type
 */
class DiplomatOwner {
public:

  inline static diplomat::result<std::unique_ptr<DiplomatOwner>, std::unique_ptr<ControllerError>> new_from_starknet_signer(std::string_view starknet_pk);

  inline const diplomat::capi::DiplomatOwner* AsFFI() const;
  inline diplomat::capi::DiplomatOwner* AsFFI();
  inline static const DiplomatOwner* FromFFI(const diplomat::capi::DiplomatOwner* ptr);
  inline static DiplomatOwner* FromFFI(diplomat::capi::DiplomatOwner* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatOwner() = delete;
  DiplomatOwner(const DiplomatOwner&) = delete;
  DiplomatOwner(DiplomatOwner&&) noexcept = delete;
  DiplomatOwner operator=(const DiplomatOwner&) = delete;
  DiplomatOwner operator=(DiplomatOwner&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatOwner_D_HPP
