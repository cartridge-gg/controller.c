#ifndef CONTROLLERS_HPP
#define CONTROLLERS_HPP

#include "CONTROLLERS.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ControllerError.hpp"
#include "Version.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct CONTROLLERS_get_class_hash_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} CONTROLLERS_get_class_hash_result;
    CONTROLLERS_get_class_hash_result CONTROLLERS_get_class_hash(diplomat::capi::Version version, diplomat::capi::DiplomatWrite* write);

    void CONTROLLERS_destroy(CONTROLLERS* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> CONTROLLERS::get_class_hash(Version version) {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::CONTROLLERS_get_class_hash(version.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> CONTROLLERS::get_class_hash_write(Version version, W& writeable) {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::CONTROLLERS_get_class_hash(version.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::CONTROLLERS* CONTROLLERS::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::CONTROLLERS*>(this);
}

inline diplomat::capi::CONTROLLERS* CONTROLLERS::AsFFI() {
  return reinterpret_cast<diplomat::capi::CONTROLLERS*>(this);
}

inline const CONTROLLERS* CONTROLLERS::FromFFI(const diplomat::capi::CONTROLLERS* ptr) {
  return reinterpret_cast<const CONTROLLERS*>(ptr);
}

inline CONTROLLERS* CONTROLLERS::FromFFI(diplomat::capi::CONTROLLERS* ptr) {
  return reinterpret_cast<CONTROLLERS*>(ptr);
}

inline void CONTROLLERS::operator delete(void* ptr) {
  diplomat::capi::CONTROLLERS_destroy(reinterpret_cast<diplomat::capi::CONTROLLERS*>(ptr));
}


#endif // CONTROLLERS_HPP
