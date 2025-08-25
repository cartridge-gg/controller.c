#ifndef DiplomatCall_HPP
#define DiplomatCall_HPP

#include "DiplomatCall.d.hpp"

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
    extern "C" {

    diplomat::capi::DiplomatCall* DiplomatCall_new(diplomat::capi::DiplomatStringView to, diplomat::capi::DiplomatStringView selector);

    void DiplomatCall_push_calldata_str(diplomat::capi::DiplomatCall* self, diplomat::capi::DiplomatStringView felt);

    void DiplomatCall_push_calldata_bytes(diplomat::capi::DiplomatCall* self, diplomat::capi::DiplomatU8View byte);

    void DiplomatCall_destroy(DiplomatCall* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<DiplomatCall> DiplomatCall::new_(std::string_view to, std::string_view selector) {
  auto result = diplomat::capi::DiplomatCall_new({to.data(), to.size()},
    {selector.data(), selector.size()});
  return std::unique_ptr<DiplomatCall>(DiplomatCall::FromFFI(result));
}

inline void DiplomatCall::push_calldata_str(std::string_view felt) {
  diplomat::capi::DiplomatCall_push_calldata_str(this->AsFFI(),
    {felt.data(), felt.size()});
}

inline void DiplomatCall::push_calldata_bytes(diplomat::span<const uint8_t> byte) {
  diplomat::capi::DiplomatCall_push_calldata_bytes(this->AsFFI(),
    {byte.data(), byte.size()});
}

inline const diplomat::capi::DiplomatCall* DiplomatCall::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatCall*>(this);
}

inline diplomat::capi::DiplomatCall* DiplomatCall::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatCall*>(this);
}

inline const DiplomatCall* DiplomatCall::FromFFI(const diplomat::capi::DiplomatCall* ptr) {
  return reinterpret_cast<const DiplomatCall*>(ptr);
}

inline DiplomatCall* DiplomatCall::FromFFI(diplomat::capi::DiplomatCall* ptr) {
  return reinterpret_cast<DiplomatCall*>(ptr);
}

inline void DiplomatCall::operator delete(void* ptr) {
  diplomat::capi::DiplomatCall_destroy(reinterpret_cast<diplomat::capi::DiplomatCall*>(ptr));
}


#endif // DiplomatCall_HPP
