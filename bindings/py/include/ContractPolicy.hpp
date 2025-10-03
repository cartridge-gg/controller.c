#ifndef ContractPolicy_HPP
#define ContractPolicy_HPP

#include "ContractPolicy.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "Method.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    diplomat::capi::ContractPolicy* ContractPolicy_new(diplomat::capi::OptionStringView name, diplomat::capi::OptionStringView description);

    void ContractPolicy_push_method(diplomat::capi::ContractPolicy* self, const diplomat::capi::Method* method);

    void ContractPolicy_destroy(ContractPolicy* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<ContractPolicy> ContractPolicy::new_(std::optional<std::string_view> name, std::optional<std::string_view> description) {
    auto result = diplomat::capi::ContractPolicy_new(name.has_value() ? (diplomat::capi::OptionStringView{ { {name.value().data(), name.value().size()} }, true }) : (diplomat::capi::OptionStringView{ {}, false }),
        description.has_value() ? (diplomat::capi::OptionStringView{ { {description.value().data(), description.value().size()} }, true }) : (diplomat::capi::OptionStringView{ {}, false }));
    return std::unique_ptr<ContractPolicy>(ContractPolicy::FromFFI(result));
}

inline void ContractPolicy::push_method(const Method& method) {
    diplomat::capi::ContractPolicy_push_method(this->AsFFI(),
        method.AsFFI());
}

inline const diplomat::capi::ContractPolicy* ContractPolicy::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::ContractPolicy*>(this);
}

inline diplomat::capi::ContractPolicy* ContractPolicy::AsFFI() {
    return reinterpret_cast<diplomat::capi::ContractPolicy*>(this);
}

inline const ContractPolicy* ContractPolicy::FromFFI(const diplomat::capi::ContractPolicy* ptr) {
    return reinterpret_cast<const ContractPolicy*>(ptr);
}

inline ContractPolicy* ContractPolicy::FromFFI(diplomat::capi::ContractPolicy* ptr) {
    return reinterpret_cast<ContractPolicy*>(ptr);
}

inline void ContractPolicy::operator delete(void* ptr) {
    diplomat::capi::ContractPolicy_destroy(reinterpret_cast<diplomat::capi::ContractPolicy*>(ptr));
}


#endif // ContractPolicy_HPP
