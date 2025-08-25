#ifndef WebauthnSigner_D_HPP
#define WebauthnSigner_D_HPP

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
    struct WebauthnSigner;
} // namespace capi
} // namespace

/**
 * Opaque wrapper for WebauthnSigner
 */
class WebauthnSigner {
public:

  inline const diplomat::capi::WebauthnSigner* AsFFI() const;
  inline diplomat::capi::WebauthnSigner* AsFFI();
  inline static const WebauthnSigner* FromFFI(const diplomat::capi::WebauthnSigner* ptr);
  inline static WebauthnSigner* FromFFI(diplomat::capi::WebauthnSigner* ptr);
  inline static void operator delete(void* ptr);
private:
  WebauthnSigner() = delete;
  WebauthnSigner(const WebauthnSigner&) = delete;
  WebauthnSigner(WebauthnSigner&&) noexcept = delete;
  WebauthnSigner operator=(const WebauthnSigner&) = delete;
  WebauthnSigner operator=(WebauthnSigner&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // WebauthnSigner_D_HPP
