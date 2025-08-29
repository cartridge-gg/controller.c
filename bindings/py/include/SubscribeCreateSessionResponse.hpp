#ifndef SubscribeCreateSessionResponse_HPP
#define SubscribeCreateSessionResponse_HPP

#include "SubscribeCreateSessionResponse.d.hpp"

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

    typedef struct SubscribeCreateSessionResponse_get_as_json_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} SubscribeCreateSessionResponse_get_as_json_result;
    SubscribeCreateSessionResponse_get_as_json_result SubscribeCreateSessionResponse_get_as_json(const diplomat::capi::SubscribeCreateSessionResponse* self, diplomat::capi::DiplomatWrite* write);

    void SubscribeCreateSessionResponse_destroy(SubscribeCreateSessionResponse* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> SubscribeCreateSessionResponse::get_as_json() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::SubscribeCreateSessionResponse_get_as_json(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> SubscribeCreateSessionResponse::get_as_json_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::SubscribeCreateSessionResponse_get_as_json(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::SubscribeCreateSessionResponse*>(this);
}

inline diplomat::capi::SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::AsFFI() {
  return reinterpret_cast<diplomat::capi::SubscribeCreateSessionResponse*>(this);
}

inline const SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::FromFFI(const diplomat::capi::SubscribeCreateSessionResponse* ptr) {
  return reinterpret_cast<const SubscribeCreateSessionResponse*>(ptr);
}

inline SubscribeCreateSessionResponse* SubscribeCreateSessionResponse::FromFFI(diplomat::capi::SubscribeCreateSessionResponse* ptr) {
  return reinterpret_cast<SubscribeCreateSessionResponse*>(ptr);
}

inline void SubscribeCreateSessionResponse::operator delete(void* ptr) {
  diplomat::capi::SubscribeCreateSessionResponse_destroy(reinterpret_cast<diplomat::capi::SubscribeCreateSessionResponse*>(ptr));
}


#endif // SubscribeCreateSessionResponse_HPP
