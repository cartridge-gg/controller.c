#ifndef Utils_HPP
#define Utils_HPP

#include "Utils.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ControllerError.hpp"
#include "DiplomatFelt.hpp"
#include "DiplomatSigner.hpp"
#include "ResponseDataOut.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct Utils_subscribe_create_session_result {union {diplomat::capi::ResponseDataOut* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} Utils_subscribe_create_session_result;
    Utils_subscribe_create_session_result Utils_subscribe_create_session(const diplomat::capi::DiplomatFelt* session_key_guid, diplomat::capi::DiplomatStringView cartridge_api_url);

    diplomat::capi::DiplomatFelt* Utils_signer_to_guid(const diplomat::capi::DiplomatSigner* signer);

    diplomat::capi::DiplomatFelt* Utils_get_public_key(const diplomat::capi::DiplomatFelt* private_key);

    void Utils_destroy(Utils* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<diplomat::result<std::unique_ptr<ResponseDataOut>, std::unique_ptr<ControllerError>>, diplomat::Utf8Error> Utils::subscribe_create_session(const DiplomatFelt& session_key_guid, std::string_view cartridge_api_url) {
    if (!diplomat::capi::diplomat_is_str(cartridge_api_url.data(), cartridge_api_url.size())) {
    return diplomat::Err<diplomat::Utf8Error>();
  }
    auto result = diplomat::capi::Utils_subscribe_create_session(session_key_guid.AsFFI(),
        {cartridge_api_url.data(), cartridge_api_url.size()});
    return diplomat::Ok<diplomat::result<std::unique_ptr<ResponseDataOut>, std::unique_ptr<ControllerError>>>(result.is_ok ? diplomat::result<std::unique_ptr<ResponseDataOut>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<ResponseDataOut>>(std::unique_ptr<ResponseDataOut>(ResponseDataOut::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<ResponseDataOut>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err)))));
}

inline std::unique_ptr<DiplomatFelt> Utils::signer_to_guid(const DiplomatSigner& signer) {
    auto result = diplomat::capi::Utils_signer_to_guid(signer.AsFFI());
    return std::unique_ptr<DiplomatFelt>(DiplomatFelt::FromFFI(result));
}

inline std::unique_ptr<DiplomatFelt> Utils::get_public_key(const DiplomatFelt& private_key) {
    auto result = diplomat::capi::Utils_get_public_key(private_key.AsFFI());
    return std::unique_ptr<DiplomatFelt>(DiplomatFelt::FromFFI(result));
}

inline const diplomat::capi::Utils* Utils::AsFFI() const {
    return reinterpret_cast<const diplomat::capi::Utils*>(this);
}

inline diplomat::capi::Utils* Utils::AsFFI() {
    return reinterpret_cast<diplomat::capi::Utils*>(this);
}

inline const Utils* Utils::FromFFI(const diplomat::capi::Utils* ptr) {
    return reinterpret_cast<const Utils*>(ptr);
}

inline Utils* Utils::FromFFI(diplomat::capi::Utils* ptr) {
    return reinterpret_cast<Utils*>(ptr);
}

inline void Utils::operator delete(void* ptr) {
    diplomat::capi::Utils_destroy(reinterpret_cast<diplomat::capi::Utils*>(ptr));
}


#endif // Utils_HPP
