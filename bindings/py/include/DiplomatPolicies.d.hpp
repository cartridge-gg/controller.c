#ifndef DiplomatPolicies_D_HPP
#define DiplomatPolicies_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct DiplomatFelt; }
class DiplomatFelt;


namespace diplomat {
namespace capi {
    struct DiplomatPolicies;
} // namespace capi
} // namespace

/**
 * Session Wrapper
 */
class DiplomatPolicies {
public:

  inline static std::unique_ptr<DiplomatPolicies> new_();

  inline void add_call(const DiplomatFelt& contract_address, const DiplomatFelt& selector);

  inline void add_typed_data(const DiplomatFelt& scope_hash);

  inline const diplomat::capi::DiplomatPolicies* AsFFI() const;
  inline diplomat::capi::DiplomatPolicies* AsFFI();
  inline static const DiplomatPolicies* FromFFI(const diplomat::capi::DiplomatPolicies* ptr);
  inline static DiplomatPolicies* FromFFI(diplomat::capi::DiplomatPolicies* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatPolicies() = delete;
  DiplomatPolicies(const DiplomatPolicies&) = delete;
  DiplomatPolicies(DiplomatPolicies&&) noexcept = delete;
  DiplomatPolicies operator=(const DiplomatPolicies&) = delete;
  DiplomatPolicies operator=(DiplomatPolicies&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatPolicies_D_HPP
