#ifndef DiplomatCall_D_HPP
#define DiplomatCall_D_HPP

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
    struct DiplomatCall;
} // namespace capi
} // namespace

class DiplomatCall {
public:

  inline static std::unique_ptr<DiplomatCall> new_(std::string_view to, std::string_view selector);

  inline void push_calldata_str(std::string_view felt);

  inline void push_calldata_bytes(diplomat::span<const uint8_t> byte);

  inline const diplomat::capi::DiplomatCall* AsFFI() const;
  inline diplomat::capi::DiplomatCall* AsFFI();
  inline static const DiplomatCall* FromFFI(const diplomat::capi::DiplomatCall* ptr);
  inline static DiplomatCall* FromFFI(diplomat::capi::DiplomatCall* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatCall() = delete;
  DiplomatCall(const DiplomatCall&) = delete;
  DiplomatCall(DiplomatCall&&) noexcept = delete;
  DiplomatCall operator=(const DiplomatCall&) = delete;
  DiplomatCall operator=(DiplomatCall&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatCall_D_HPP
