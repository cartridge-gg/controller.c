#ifndef DiplomatSigner_HPP
#define DiplomatSigner_HPP

#include "DiplomatSigner.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "DiplomatFelt.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    diplomat::capi::DiplomatSigner* DiplomatSigner_new_starknet_signer(const diplomat::capi::DiplomatFelt* secret_scalar);

    void DiplomatSigner_destroy(DiplomatSigner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<DiplomatSigner> DiplomatSigner::new_starknet_signer(const DiplomatFelt& secret_scalar) {
  auto result = diplomat::capi::DiplomatSigner_new_starknet_signer(secret_scalar.AsFFI());
  return std::unique_ptr<DiplomatSigner>(DiplomatSigner::FromFFI(result));
}

inline const diplomat::capi::DiplomatSigner* DiplomatSigner::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatSigner*>(this);
}

inline diplomat::capi::DiplomatSigner* DiplomatSigner::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatSigner*>(this);
}

inline const DiplomatSigner* DiplomatSigner::FromFFI(const diplomat::capi::DiplomatSigner* ptr) {
  return reinterpret_cast<const DiplomatSigner*>(ptr);
}

inline DiplomatSigner* DiplomatSigner::FromFFI(diplomat::capi::DiplomatSigner* ptr) {
  return reinterpret_cast<DiplomatSigner*>(ptr);
}

inline void DiplomatSigner::operator delete(void* ptr) {
  diplomat::capi::DiplomatSigner_destroy(reinterpret_cast<diplomat::capi::DiplomatSigner*>(ptr));
}


#endif // DiplomatSigner_HPP
