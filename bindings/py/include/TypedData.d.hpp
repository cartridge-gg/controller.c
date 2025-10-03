#ifndef TypedData_D_HPP
#define TypedData_D_HPP

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
    struct TypedData;
} // namespace capi
} // namespace

class TypedData {
public:

    inline const diplomat::capi::TypedData* AsFFI() const;
    inline diplomat::capi::TypedData* AsFFI();
    inline static const TypedData* FromFFI(const diplomat::capi::TypedData* ptr);
    inline static TypedData* FromFFI(diplomat::capi::TypedData* ptr);
    inline static void operator delete(void* ptr);
private:
    TypedData() = delete;
    TypedData(const TypedData&) = delete;
    TypedData(TypedData&&) noexcept = delete;
    TypedData operator=(const TypedData&) = delete;
    TypedData operator=(TypedData&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // TypedData_D_HPP
