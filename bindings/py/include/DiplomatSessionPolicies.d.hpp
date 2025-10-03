#ifndef DiplomatSessionPolicies_D_HPP
#define DiplomatSessionPolicies_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct ContractPolicy; }
class ContractPolicy;
namespace diplomat::capi { struct SignMessagePolicy; }
class SignMessagePolicy;


namespace diplomat {
namespace capi {
    struct DiplomatSessionPolicies;
} // namespace capi
} // namespace

class DiplomatSessionPolicies {
public:

  inline static std::unique_ptr<DiplomatSessionPolicies> new_();

  inline diplomat::result<std::monostate, diplomat::Utf8Error> add_contract_policy(std::string_view address, const ContractPolicy& policy);

  inline void add_message_policy(const SignMessagePolicy& policy);

  inline std::string to_url_string() const;
  template<typename W>
  inline void to_url_string_write(W& writeable_output) const;

    inline const diplomat::capi::DiplomatSessionPolicies* AsFFI() const;
    inline diplomat::capi::DiplomatSessionPolicies* AsFFI();
    inline static const DiplomatSessionPolicies* FromFFI(const diplomat::capi::DiplomatSessionPolicies* ptr);
    inline static DiplomatSessionPolicies* FromFFI(diplomat::capi::DiplomatSessionPolicies* ptr);
    inline static void operator delete(void* ptr);
private:
    DiplomatSessionPolicies() = delete;
    DiplomatSessionPolicies(const DiplomatSessionPolicies&) = delete;
    DiplomatSessionPolicies(DiplomatSessionPolicies&&) noexcept = delete;
    DiplomatSessionPolicies operator=(const DiplomatSessionPolicies&) = delete;
    DiplomatSessionPolicies operator=(DiplomatSessionPolicies&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatSessionPolicies_D_HPP
