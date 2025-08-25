#ifndef DiplomatFelt_D_HPP
#define DiplomatFelt_D_HPP

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
    struct DiplomatFelt;
} // namespace capi
} // namespace

class DiplomatFelt {
public:

  inline static diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>> new_from_hex(std::string_view hex);

  inline static diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>> new_from_bytes(diplomat::span<const uint8_t> bytes);

  inline const diplomat::capi::DiplomatFelt* AsFFI() const;
  inline diplomat::capi::DiplomatFelt* AsFFI();
  inline static const DiplomatFelt* FromFFI(const diplomat::capi::DiplomatFelt* ptr);
  inline static DiplomatFelt* FromFFI(diplomat::capi::DiplomatFelt* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatFelt() = delete;
  DiplomatFelt(const DiplomatFelt&) = delete;
  DiplomatFelt(DiplomatFelt&&) noexcept = delete;
  DiplomatFelt operator=(const DiplomatFelt&) = delete;
  DiplomatFelt operator=(DiplomatFelt&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatFelt_D_HPP
