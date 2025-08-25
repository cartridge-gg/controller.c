#ifndef DiplomatSigner_D_HPP
#define DiplomatSigner_D_HPP

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
    struct DiplomatSigner;
} // namespace capi
} // namespace

/**
 * Opaque wrapper for complex Signer type
 */
class DiplomatSigner {
public:

  inline const diplomat::capi::DiplomatSigner* AsFFI() const;
  inline diplomat::capi::DiplomatSigner* AsFFI();
  inline static const DiplomatSigner* FromFFI(const diplomat::capi::DiplomatSigner* ptr);
  inline static DiplomatSigner* FromFFI(diplomat::capi::DiplomatSigner* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatSigner() = delete;
  DiplomatSigner(const DiplomatSigner&) = delete;
  DiplomatSigner(DiplomatSigner&&) noexcept = delete;
  DiplomatSigner operator=(const DiplomatSigner&) = delete;
  DiplomatSigner operator=(DiplomatSigner&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatSigner_D_HPP
