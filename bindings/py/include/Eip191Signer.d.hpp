#ifndef Eip191Signer_D_HPP
#define Eip191Signer_D_HPP

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
    struct Eip191Signer;
} // namespace capi
} // namespace

/**
 * Opaque wrapper for Eip191Signer
 */
class Eip191Signer {
public:

  inline const diplomat::capi::Eip191Signer* AsFFI() const;
  inline diplomat::capi::Eip191Signer* AsFFI();
  inline static const Eip191Signer* FromFFI(const diplomat::capi::Eip191Signer* ptr);
  inline static Eip191Signer* FromFFI(diplomat::capi::Eip191Signer* ptr);
  inline static void operator delete(void* ptr);
private:
  Eip191Signer() = delete;
  Eip191Signer(const Eip191Signer&) = delete;
  Eip191Signer(Eip191Signer&&) noexcept = delete;
  Eip191Signer operator=(const Eip191Signer&) = delete;
  Eip191Signer operator=(Eip191Signer&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // Eip191Signer_D_HPP
