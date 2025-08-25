#ifndef ErrorUtils_D_HPP
#define ErrorUtils_D_HPP

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
    struct ErrorUtils;
} // namespace capi
} // namespace

/**
 * Error utility functions
 */
class ErrorUtils {
public:

  /**
   * Get the last error message that occurred
   * This is a workaround for Python bindings not properly extracting error messages
   */
  inline static std::string get_last_error_message();
  template<typename W>
  inline static void get_last_error_message_write(W& writeable_output);

  /**
   * Clear the last error message
   */
  inline static void clear_last_error();

  inline const diplomat::capi::ErrorUtils* AsFFI() const;
  inline diplomat::capi::ErrorUtils* AsFFI();
  inline static const ErrorUtils* FromFFI(const diplomat::capi::ErrorUtils* ptr);
  inline static ErrorUtils* FromFFI(diplomat::capi::ErrorUtils* ptr);
  inline static void operator delete(void* ptr);
private:
  ErrorUtils() = delete;
  ErrorUtils(const ErrorUtils&) = delete;
  ErrorUtils(ErrorUtils&&) noexcept = delete;
  ErrorUtils operator=(const ErrorUtils&) = delete;
  ErrorUtils operator=(ErrorUtils&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // ErrorUtils_D_HPP
