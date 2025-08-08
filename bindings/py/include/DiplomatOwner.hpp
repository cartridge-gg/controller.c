#ifndef DiplomatOwner_HPP
#define DiplomatOwner_HPP

#include "DiplomatOwner.d.hpp"

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

    typedef struct DiplomatOwner_new_from_starknet_signer_result {union {diplomat::capi::DiplomatOwner* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} DiplomatOwner_new_from_starknet_signer_result;
    DiplomatOwner_new_from_starknet_signer_result DiplomatOwner_new_from_starknet_signer(diplomat::capi::DiplomatStringView starknet_pk);

    void DiplomatOwner_destroy(DiplomatOwner* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::unique_ptr<DiplomatOwner>, std::unique_ptr<ControllerError>> DiplomatOwner::new_from_starknet_signer(std::string_view starknet_pk) {
  auto result = diplomat::capi::DiplomatOwner_new_from_starknet_signer({starknet_pk.data(), starknet_pk.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<DiplomatOwner>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<DiplomatOwner>>(std::unique_ptr<DiplomatOwner>(DiplomatOwner::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<DiplomatOwner>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::DiplomatOwner* DiplomatOwner::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatOwner*>(this);
}

inline diplomat::capi::DiplomatOwner* DiplomatOwner::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatOwner*>(this);
}

inline const DiplomatOwner* DiplomatOwner::FromFFI(const diplomat::capi::DiplomatOwner* ptr) {
  return reinterpret_cast<const DiplomatOwner*>(ptr);
}

inline DiplomatOwner* DiplomatOwner::FromFFI(diplomat::capi::DiplomatOwner* ptr) {
  return reinterpret_cast<DiplomatOwner*>(ptr);
}

inline void DiplomatOwner::operator delete(void* ptr) {
  diplomat::capi::DiplomatOwner_destroy(reinterpret_cast<diplomat::capi::DiplomatOwner*>(ptr));
}


#endif // DiplomatOwner_HPP
