#ifndef DiplomatFelt_HPP
#define DiplomatFelt_HPP

#include "DiplomatFelt.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ControllerError.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct DiplomatFelt_new_from_hex_result {union {diplomat::capi::DiplomatFelt* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} DiplomatFelt_new_from_hex_result;
    DiplomatFelt_new_from_hex_result DiplomatFelt_new_from_hex(diplomat::capi::DiplomatStringView hex);

    typedef struct DiplomatFelt_new_from_bytes_result {union {diplomat::capi::DiplomatFelt* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} DiplomatFelt_new_from_bytes_result;
    DiplomatFelt_new_from_bytes_result DiplomatFelt_new_from_bytes(diplomat::capi::DiplomatU8View bytes);

    void DiplomatFelt_destroy(DiplomatFelt* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>> DiplomatFelt::new_from_hex(std::string_view hex) {
  auto result = diplomat::capi::DiplomatFelt_new_from_hex({hex.data(), hex.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<DiplomatFelt>>(std::unique_ptr<DiplomatFelt>(DiplomatFelt::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>> DiplomatFelt::new_from_bytes(diplomat::span<const uint8_t> bytes) {
  auto result = diplomat::capi::DiplomatFelt_new_from_bytes({bytes.data(), bytes.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<DiplomatFelt>>(std::unique_ptr<DiplomatFelt>(DiplomatFelt::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<DiplomatFelt>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::DiplomatFelt* DiplomatFelt::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatFelt*>(this);
}

inline diplomat::capi::DiplomatFelt* DiplomatFelt::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatFelt*>(this);
}

inline const DiplomatFelt* DiplomatFelt::FromFFI(const diplomat::capi::DiplomatFelt* ptr) {
  return reinterpret_cast<const DiplomatFelt*>(ptr);
}

inline DiplomatFelt* DiplomatFelt::FromFFI(diplomat::capi::DiplomatFelt* ptr) {
  return reinterpret_cast<DiplomatFelt*>(ptr);
}

inline void DiplomatFelt::operator delete(void* ptr) {
  diplomat::capi::DiplomatFelt_destroy(reinterpret_cast<diplomat::capi::DiplomatFelt*>(ptr));
}


#endif // DiplomatFelt_HPP
