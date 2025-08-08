#ifndef WebauthnSigner_HPP
#define WebauthnSigner_HPP

#include "WebauthnSigner.d.hpp"

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

    void WebauthnSigner_destroy(WebauthnSigner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline const diplomat::capi::WebauthnSigner* WebauthnSigner::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::WebauthnSigner*>(this);
}

inline diplomat::capi::WebauthnSigner* WebauthnSigner::AsFFI() {
  return reinterpret_cast<diplomat::capi::WebauthnSigner*>(this);
}

inline const WebauthnSigner* WebauthnSigner::FromFFI(const diplomat::capi::WebauthnSigner* ptr) {
  return reinterpret_cast<const WebauthnSigner*>(ptr);
}

inline WebauthnSigner* WebauthnSigner::FromFFI(diplomat::capi::WebauthnSigner* ptr) {
  return reinterpret_cast<WebauthnSigner*>(ptr);
}

inline void WebauthnSigner::operator delete(void* ptr) {
  diplomat::capi::WebauthnSigner_destroy(reinterpret_cast<diplomat::capi::WebauthnSigner*>(ptr));
}


#endif // WebauthnSigner_HPP
