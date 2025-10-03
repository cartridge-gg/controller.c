#ifndef ControllerError_D_HPP
#define ControllerError_D_HPP

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
    struct ControllerError;
} // namespace capi
} // namespace

/**
 * Error types for controller operations
 *
 * See the [Rust documentation for `Display`](https://docs.rs/std/latest/std/fmt/trait.Display.html) for more information.
 */
class ControllerError {
public:

  /**
     * Gets the error message
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> message() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> message_write(W& writeable_output) const;

  /**
     * Gets the error message as a string (for Python bindings)
     * This always returns Ok so the error message can be extracted
   */
  inline std::string get_message_string() const;
  template<typename W>
  inline void get_message_string_write(W& writeable_output) const;

    inline const diplomat::capi::ControllerError* AsFFI() const;
    inline diplomat::capi::ControllerError* AsFFI();
    inline static const ControllerError* FromFFI(const diplomat::capi::ControllerError* ptr);
    inline static ControllerError* FromFFI(diplomat::capi::ControllerError* ptr);
    inline static void operator delete(void* ptr);
private:
    ControllerError() = delete;
    ControllerError(const ControllerError&) = delete;
    ControllerError(ControllerError&&) noexcept = delete;
    ControllerError operator=(const ControllerError&) = delete;
    ControllerError operator=(ControllerError&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // ControllerError_D_HPP
