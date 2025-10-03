#ifndef SessionAccountInner_D_HPP
#define SessionAccountInner_D_HPP

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
    struct SessionAccountInner;
} // namespace capi
} // namespace

/**
 * Session Account Wrapper
 */
class SessionAccountInner {
public:

    inline const diplomat::capi::SessionAccountInner* AsFFI() const;
    inline diplomat::capi::SessionAccountInner* AsFFI();
    inline static const SessionAccountInner* FromFFI(const diplomat::capi::SessionAccountInner* ptr);
    inline static SessionAccountInner* FromFFI(diplomat::capi::SessionAccountInner* ptr);
    inline static void operator delete(void* ptr);
private:
    SessionAccountInner() = delete;
    SessionAccountInner(const SessionAccountInner&) = delete;
    SessionAccountInner(SessionAccountInner&&) noexcept = delete;
    SessionAccountInner operator=(const SessionAccountInner&) = delete;
    SessionAccountInner operator=(SessionAccountInner&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // SessionAccountInner_D_HPP
