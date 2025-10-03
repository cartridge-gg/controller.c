#ifndef Method_HPP
#define Method_HPP

#include "Method.d.hpp"

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
    extern "C" {

    diplomat::capi::Method* Method_new(diplomat::capi::DiplomatStringView name, diplomat::capi::DiplomatStringView description, diplomat::capi::DiplomatStringView entrypoint, bool is_enabled, bool is_required, bool is_paymastered);

    void Method_destroy(Method* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::unique_ptr<Method>, diplomat::Utf8Error> Method::new_(std::string_view name, std::string_view description, std::string_view entrypoint, bool is_enabled, bool is_required, bool is_paymastered) {
    if (!diplomat::capi::diplomat_is_str(name.data(), name.size())) {
    return diplomat::Err<diplomat::Utf8Error>();
  }
    if (!diplomat::capi::diplomat_is_str(description.data(), description.size())) {
    return diplomat::Err<diplomat::Utf8Error>();
  }
    if (!diplomat::capi::diplomat_is_str(entrypoint.data(), entrypoint.size())) {
    return diplomat::Err<diplomat::Utf8Error>();
  }
    auto result = diplomat::capi::Method_new({name.data(), name.size()},
        {description.data(), description.size()},
        {entrypoint.data(), entrypoint.size()},
        is_enabled,
        is_required,
        is_paymastered);
    return diplomat::Ok<std::unique_ptr<Method>>(std::unique_ptr<Method>(Method::FromFFI(result)));
}

inline const diplomat::capi::Method* Method::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::Method*>(this);
}

inline diplomat::capi::Method* Method::AsFFI() {
    return reinterpret_cast<diplomat::capi::Method*>(this);
}

inline const Method* Method::FromFFI(const diplomat::capi::Method* ptr) {
    return reinterpret_cast<const Method*>(ptr);
}

inline Method* Method::FromFFI(diplomat::capi::Method* ptr) {
    return reinterpret_cast<Method*>(ptr);
}

inline void Method::operator delete(void* ptr) {
    diplomat::capi::Method_destroy(reinterpret_cast<diplomat::capi::Method*>(ptr));
}


#endif // Method_HPP
