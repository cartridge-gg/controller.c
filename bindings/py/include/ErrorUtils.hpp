#ifndef ErrorUtils_HPP
#define ErrorUtils_HPP

#include "ErrorUtils.d.hpp"

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

    void ErrorUtils_get_last_error_message(diplomat::capi::DiplomatWrite* write);

    void ErrorUtils_clear_last_error(void);

    void ErrorUtils_destroy(ErrorUtils* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::string ErrorUtils::get_last_error_message() {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  diplomat::capi::ErrorUtils_get_last_error_message(&write);
  return output;
}
template<typename W>
inline void ErrorUtils::get_last_error_message_write(W& writeable) {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  diplomat::capi::ErrorUtils_get_last_error_message(&write);
}

inline void ErrorUtils::clear_last_error() {
  diplomat::capi::ErrorUtils_clear_last_error();
}

inline const diplomat::capi::ErrorUtils* ErrorUtils::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::ErrorUtils*>(this);
}

inline diplomat::capi::ErrorUtils* ErrorUtils::AsFFI() {
  return reinterpret_cast<diplomat::capi::ErrorUtils*>(this);
}

inline const ErrorUtils* ErrorUtils::FromFFI(const diplomat::capi::ErrorUtils* ptr) {
  return reinterpret_cast<const ErrorUtils*>(ptr);
}

inline ErrorUtils* ErrorUtils::FromFFI(diplomat::capi::ErrorUtils* ptr) {
  return reinterpret_cast<ErrorUtils*>(ptr);
}

inline void ErrorUtils::operator delete(void* ptr) {
  diplomat::capi::ErrorUtils_destroy(reinterpret_cast<diplomat::capi::ErrorUtils*>(ptr));
}


#endif // ErrorUtils_HPP
