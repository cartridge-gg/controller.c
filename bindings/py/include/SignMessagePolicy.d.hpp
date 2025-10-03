#ifndef SignMessagePolicy_D_HPP
#define SignMessagePolicy_D_HPP

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
    struct SignMessagePolicy;
} // namespace capi
} // namespace

class SignMessagePolicy {
public:

    inline const diplomat::capi::SignMessagePolicy* AsFFI() const;
    inline diplomat::capi::SignMessagePolicy* AsFFI();
    inline static const SignMessagePolicy* FromFFI(const diplomat::capi::SignMessagePolicy* ptr);
    inline static SignMessagePolicy* FromFFI(diplomat::capi::SignMessagePolicy* ptr);
    inline static void operator delete(void* ptr);
private:
    SignMessagePolicy() = delete;
    SignMessagePolicy(const SignMessagePolicy&) = delete;
    SignMessagePolicy(SignMessagePolicy&&) noexcept = delete;
    SignMessagePolicy operator=(const SignMessagePolicy&) = delete;
    SignMessagePolicy operator=(SignMessagePolicy&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // SignMessagePolicy_D_HPP
