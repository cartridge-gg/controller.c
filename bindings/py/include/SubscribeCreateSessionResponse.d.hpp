#ifndef SubscribeCreateSessionResponse_D_HPP
#define SubscribeCreateSessionResponse_D_HPP

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
    struct SubscribeCreateSessionResponse;
} // namespace capi
} // namespace

class SubscribeCreateSessionResponse {
public:

    inline const diplomat::capi::SubscribeCreateSessionResponse* AsFFI() const;
    inline diplomat::capi::SubscribeCreateSessionResponse* AsFFI();
    inline static const SubscribeCreateSessionResponse* FromFFI(const diplomat::capi::SubscribeCreateSessionResponse* ptr);
    inline static SubscribeCreateSessionResponse* FromFFI(diplomat::capi::SubscribeCreateSessionResponse* ptr);
    inline static void operator delete(void* ptr);
private:
    SubscribeCreateSessionResponse() = delete;
    SubscribeCreateSessionResponse(const SubscribeCreateSessionResponse&) = delete;
    SubscribeCreateSessionResponse(SubscribeCreateSessionResponse&&) noexcept = delete;
    SubscribeCreateSessionResponse operator=(const SubscribeCreateSessionResponse&) = delete;
    SubscribeCreateSessionResponse operator=(SubscribeCreateSessionResponse&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // SubscribeCreateSessionResponse_D_HPP
