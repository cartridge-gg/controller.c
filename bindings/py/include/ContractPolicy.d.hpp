#ifndef ContractPolicy_D_HPP
#define ContractPolicy_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct Method; }
class Method;


namespace diplomat {
namespace capi {
    struct ContractPolicy;
} // namespace capi
} // namespace

class ContractPolicy {
public:

  inline static std::unique_ptr<ContractPolicy> new_(std::optional<std::string_view> name, std::optional<std::string_view> description);

  inline void push_method(const Method& method);

    inline const diplomat::capi::ContractPolicy* AsFFI() const;
    inline diplomat::capi::ContractPolicy* AsFFI();
    inline static const ContractPolicy* FromFFI(const diplomat::capi::ContractPolicy* ptr);
    inline static ContractPolicy* FromFFI(diplomat::capi::ContractPolicy* ptr);
    inline static void operator delete(void* ptr);
private:
    ContractPolicy() = delete;
    ContractPolicy(const ContractPolicy&) = delete;
    ContractPolicy(ContractPolicy&&) noexcept = delete;
    ContractPolicy operator=(const ContractPolicy&) = delete;
    ContractPolicy operator=(ContractPolicy&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // ContractPolicy_D_HPP
