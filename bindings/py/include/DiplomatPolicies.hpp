#ifndef DiplomatPolicies_HPP
#define DiplomatPolicies_HPP

#include "DiplomatPolicies.d.hpp"

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

    diplomat::capi::DiplomatPolicies* DiplomatPolicies_new(void);

    void DiplomatPolicies_add_call(diplomat::capi::DiplomatPolicies* self, const diplomat::capi::DiplomatFelt* contract_address, const diplomat::capi::DiplomatFelt* selector);

    void DiplomatPolicies_add_typed_data(diplomat::capi::DiplomatPolicies* self, const diplomat::capi::DiplomatFelt* scope_hash);

    void DiplomatPolicies_destroy(DiplomatPolicies* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<DiplomatPolicies> DiplomatPolicies::new_() {
  auto result = diplomat::capi::DiplomatPolicies_new();
  return std::unique_ptr<DiplomatPolicies>(DiplomatPolicies::FromFFI(result));
}

inline void DiplomatPolicies::add_call(const DiplomatFelt& contract_address, const DiplomatFelt& selector) {
  diplomat::capi::DiplomatPolicies_add_call(this->AsFFI(),
    contract_address.AsFFI(),
    selector.AsFFI());
}

inline void DiplomatPolicies::add_typed_data(const DiplomatFelt& scope_hash) {
  diplomat::capi::DiplomatPolicies_add_typed_data(this->AsFFI(),
    scope_hash.AsFFI());
}

inline const diplomat::capi::DiplomatPolicies* DiplomatPolicies::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatPolicies*>(this);
}

inline diplomat::capi::DiplomatPolicies* DiplomatPolicies::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatPolicies*>(this);
}

inline const DiplomatPolicies* DiplomatPolicies::FromFFI(const diplomat::capi::DiplomatPolicies* ptr) {
  return reinterpret_cast<const DiplomatPolicies*>(ptr);
}

inline DiplomatPolicies* DiplomatPolicies::FromFFI(diplomat::capi::DiplomatPolicies* ptr) {
  return reinterpret_cast<DiplomatPolicies*>(ptr);
}

inline void DiplomatPolicies::operator delete(void* ptr) {
  diplomat::capi::DiplomatPolicies_destroy(reinterpret_cast<diplomat::capi::DiplomatPolicies*>(ptr));
}


#endif // DiplomatPolicies_HPP
