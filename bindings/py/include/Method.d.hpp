#ifndef Method_D_HPP
#define Method_D_HPP

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
    struct Method;
} // namespace capi
} // namespace

class Method {
public:

  inline static diplomat::result<std::unique_ptr<Method>, diplomat::Utf8Error> new_(std::string_view name, std::string_view description, std::string_view entrypoint, bool is_enabled, bool is_required, bool is_paymastered);

    inline const diplomat::capi::Method* AsFFI() const;
    inline diplomat::capi::Method* AsFFI();
    inline static const Method* FromFFI(const diplomat::capi::Method* ptr);
    inline static Method* FromFFI(diplomat::capi::Method* ptr);
    inline static void operator delete(void* ptr);
private:
    Method() = delete;
    Method(const Method&) = delete;
    Method(Method&&) noexcept = delete;
    Method operator=(const Method&) = delete;
    Method operator=(Method&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // Method_D_HPP
