#ifndef ResponseDataOut_D_HPP
#define ResponseDataOut_D_HPP

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
    struct ResponseDataOut;
} // namespace capi
} // namespace

class ResponseDataOut {
public:

    inline const diplomat::capi::ResponseDataOut* AsFFI() const;
    inline diplomat::capi::ResponseDataOut* AsFFI();
    inline static const ResponseDataOut* FromFFI(const diplomat::capi::ResponseDataOut* ptr);
    inline static ResponseDataOut* FromFFI(diplomat::capi::ResponseDataOut* ptr);
    inline static void operator delete(void* ptr);
private:
    ResponseDataOut() = delete;
    ResponseDataOut(const ResponseDataOut&) = delete;
    ResponseDataOut(ResponseDataOut&&) noexcept = delete;
    ResponseDataOut operator=(const ResponseDataOut&) = delete;
    ResponseDataOut operator=(ResponseDataOut&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // ResponseDataOut_D_HPP
