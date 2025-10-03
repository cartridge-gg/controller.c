#ifndef StarknetType_D_HPP
#define StarknetType_D_HPP

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
    struct StarknetType;
} // namespace capi
} // namespace

class StarknetType {
public:

    inline const diplomat::capi::StarknetType* AsFFI() const;
    inline diplomat::capi::StarknetType* AsFFI();
    inline static const StarknetType* FromFFI(const diplomat::capi::StarknetType* ptr);
    inline static StarknetType* FromFFI(diplomat::capi::StarknetType* ptr);
    inline static void operator delete(void* ptr);
private:
    StarknetType() = delete;
    StarknetType(const StarknetType&) = delete;
    StarknetType(StarknetType&&) noexcept = delete;
    StarknetType operator=(const StarknetType&) = delete;
    StarknetType operator=(StarknetType&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // StarknetType_D_HPP
