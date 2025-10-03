#ifndef DiplomatSessionPolicies_HPP
#define DiplomatSessionPolicies_HPP

#include "DiplomatSessionPolicies.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ContractPolicy.hpp"
#include "SignMessagePolicy.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    diplomat::capi::DiplomatSessionPolicies* DiplomatSessionPolicies_new(void);

    void DiplomatSessionPolicies_add_contract_policy(diplomat::capi::DiplomatSessionPolicies* self, diplomat::capi::DiplomatStringView address, const diplomat::capi::ContractPolicy* policy);

    void DiplomatSessionPolicies_add_message_policy(diplomat::capi::DiplomatSessionPolicies* self, const diplomat::capi::SignMessagePolicy* policy);

    void DiplomatSessionPolicies_to_url_string(const diplomat::capi::DiplomatSessionPolicies* self, diplomat::capi::DiplomatWrite* write);

    void DiplomatSessionPolicies_destroy(DiplomatSessionPolicies* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<DiplomatSessionPolicies> DiplomatSessionPolicies::new_() {
    auto result = diplomat::capi::DiplomatSessionPolicies_new();
    return std::unique_ptr<DiplomatSessionPolicies>(DiplomatSessionPolicies::FromFFI(result));
}

inline diplomat::result<std::monostate, diplomat::Utf8Error> DiplomatSessionPolicies::add_contract_policy(std::string_view address, const ContractPolicy& policy) {
    if (!diplomat::capi::diplomat_is_str(address.data(), address.size())) {
    return diplomat::Err<diplomat::Utf8Error>();
  }
    diplomat::capi::DiplomatSessionPolicies_add_contract_policy(this->AsFFI(),
        {address.data(), address.size()},
        policy.AsFFI());
    return diplomat::Ok<std::monostate>();
}

inline void DiplomatSessionPolicies::add_message_policy(const SignMessagePolicy& policy) {
    diplomat::capi::DiplomatSessionPolicies_add_message_policy(this->AsFFI(),
        policy.AsFFI());
}

inline std::string DiplomatSessionPolicies::to_url_string() const {
    std::string output;
    diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
    diplomat::capi::DiplomatSessionPolicies_to_url_string(this->AsFFI(),
        &write);
    return output;
}
template<typename W>
inline void DiplomatSessionPolicies::to_url_string_write(W& writeable) const {
    diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
    diplomat::capi::DiplomatSessionPolicies_to_url_string(this->AsFFI(),
        &write);
}

inline const diplomat::capi::DiplomatSessionPolicies* DiplomatSessionPolicies::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::DiplomatSessionPolicies*>(this);
}

inline diplomat::capi::DiplomatSessionPolicies* DiplomatSessionPolicies::AsFFI() {
    return reinterpret_cast<diplomat::capi::DiplomatSessionPolicies*>(this);
}

inline const DiplomatSessionPolicies* DiplomatSessionPolicies::FromFFI(const diplomat::capi::DiplomatSessionPolicies* ptr) {
    return reinterpret_cast<const DiplomatSessionPolicies*>(ptr);
}

inline DiplomatSessionPolicies* DiplomatSessionPolicies::FromFFI(diplomat::capi::DiplomatSessionPolicies* ptr) {
    return reinterpret_cast<DiplomatSessionPolicies*>(ptr);
}

inline void DiplomatSessionPolicies::operator delete(void* ptr) {
    diplomat::capi::DiplomatSessionPolicies_destroy(reinterpret_cast<diplomat::capi::DiplomatSessionPolicies*>(ptr));
}


#endif // DiplomatSessionPolicies_HPP
