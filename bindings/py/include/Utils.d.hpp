#ifndef Utils_D_HPP
#define Utils_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct ControllerError; }
class ControllerError;
namespace diplomat::capi { struct DiplomatFelt; }
class DiplomatFelt;
namespace diplomat::capi { struct DiplomatSigner; }
class DiplomatSigner;
namespace diplomat::capi { struct ResponseDataOut; }
class ResponseDataOut;


namespace diplomat {
namespace capi {
    struct Utils;
} // namespace capi
} // namespace

class Utils {
public:

  inline static diplomat::result<diplomat::result<std::unique_ptr<ResponseDataOut>, std::unique_ptr<ControllerError>>, diplomat::Utf8Error> subscribe_create_session(const DiplomatFelt& session_key_guid, std::string_view cartridge_api_url);

  inline static std::unique_ptr<DiplomatFelt> signer_to_guid(const DiplomatSigner& signer);

  inline static std::unique_ptr<DiplomatFelt> get_public_key(const DiplomatFelt& private_key);

    inline const diplomat::capi::Utils* AsFFI() const;
    inline diplomat::capi::Utils* AsFFI();
    inline static const Utils* FromFFI(const diplomat::capi::Utils* ptr);
    inline static Utils* FromFFI(diplomat::capi::Utils* ptr);
    inline static void operator delete(void* ptr);
private:
    Utils() = delete;
    Utils(const Utils&) = delete;
    Utils(Utils&&) noexcept = delete;
    Utils operator=(const Utils&) = delete;
    Utils operator=(Utils&&) noexcept = delete;
    static void operator delete[](void*, size_t) = delete;
};


#endif // Utils_D_HPP
