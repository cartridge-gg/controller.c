#ifndef StarknetSigner_D_HPP
#define StarknetSigner_D_HPP

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
    struct StarknetSigner;
} // namespace capi
} // namespace

/**
 * Opaque wrapper for StarknetSigner
 */
class StarknetSigner {
public:

  inline const diplomat::capi::StarknetSigner* AsFFI() const;
  inline diplomat::capi::StarknetSigner* AsFFI();
  inline static const StarknetSigner* FromFFI(const diplomat::capi::StarknetSigner* ptr);
  inline static StarknetSigner* FromFFI(diplomat::capi::StarknetSigner* ptr);
  inline static void operator delete(void* ptr);
private:
  StarknetSigner() = delete;
  StarknetSigner(const StarknetSigner&) = delete;
  StarknetSigner(StarknetSigner&&) noexcept = delete;
  StarknetSigner operator=(const StarknetSigner&) = delete;
  StarknetSigner operator=(StarknetSigner&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // StarknetSigner_D_HPP
