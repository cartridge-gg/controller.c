#ifndef ControllerError_HPP
#define ControllerError_HPP

#include "ControllerError.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ErrorType.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct ControllerError_message_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} ControllerError_message_result;
    ControllerError_message_result ControllerError_message(const diplomat::capi::ControllerError* self, diplomat::capi::DiplomatWrite* write);

    diplomat::capi::ErrorType ControllerError_error_type(const diplomat::capi::ControllerError* self);

    void ControllerError_destroy(ControllerError* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> ControllerError::message() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::ControllerError_message(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> ControllerError::message_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::ControllerError_message(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline ErrorType ControllerError::error_type() const {
  auto result = diplomat::capi::ControllerError_error_type(this->AsFFI());
  return ErrorType::FromFFI(result);
}

inline const diplomat::capi::ControllerError* ControllerError::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::ControllerError*>(this);
}

inline diplomat::capi::ControllerError* ControllerError::AsFFI() {
  return reinterpret_cast<diplomat::capi::ControllerError*>(this);
}

inline const ControllerError* ControllerError::FromFFI(const diplomat::capi::ControllerError* ptr) {
  return reinterpret_cast<const ControllerError*>(ptr);
}

inline ControllerError* ControllerError::FromFFI(diplomat::capi::ControllerError* ptr) {
  return reinterpret_cast<ControllerError*>(ptr);
}

inline void ControllerError::operator delete(void* ptr) {
  diplomat::capi::ControllerError_destroy(reinterpret_cast<diplomat::capi::ControllerError*>(ptr));
}


#endif // ControllerError_HPP
