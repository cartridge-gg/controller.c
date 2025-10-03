#ifndef StarknetDomain_D_HPP
#define StarknetDomain_D_HPP

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
    struct StarknetDomain;
} // namespace capi
} // namespace

class StarknetDomain {
public:

    inline const diplomat::capi::StarknetDomain* AsFFI() const;
    inline diplomat::capi::StarknetDomain* AsFFI();
    inline static const StarknetDomain* FromFFI(const diplomat::capi::StarknetDomain* ptr);
    inline static StarknetDomain* FromFFI(diplomat::capi::StarknetDomain* ptr);
    inline static void operator delete(void* ptr);
private:
    StarknetDomain() = delete;
    StarknetDomain(const StarknetDomain&) = delete;
    StarknetDomain(StarknetDomain&&) noexcept = delete;
    StarknetDomain operator=(const StarknetDomain&) = delete;
    StarknetDomain operator=(StarknetDomain&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // StarknetDomain_D_HPP
