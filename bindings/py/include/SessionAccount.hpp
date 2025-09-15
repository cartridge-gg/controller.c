#ifndef SessionAccount_HPP
#define SessionAccount_HPP

#include "SessionAccount.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "ControllerError.hpp"
#include "DiplomatCallList.hpp"
#include "DiplomatFelt.hpp"
#include "DiplomatPolicies.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct SessionAccount_new_as_registered_result {union {diplomat::capi::SessionAccount* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} SessionAccount_new_as_registered_result;
    SessionAccount_new_as_registered_result SessionAccount_new_as_registered(diplomat::capi::DiplomatStringView rpc_url, const diplomat::capi::DiplomatFelt* signer, const diplomat::capi::DiplomatFelt* address, const diplomat::capi::DiplomatFelt* owner_guid, const diplomat::capi::DiplomatFelt* chain_id, const diplomat::capi::DiplomatPolicies* policies, uint64_t session_expiration);

    typedef struct SessionAccount_execute_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} SessionAccount_execute_result;
    SessionAccount_execute_result SessionAccount_execute(const diplomat::capi::SessionAccount* self, const diplomat::capi::DiplomatCallList* calls, diplomat::capi::DiplomatWrite* write);

    typedef struct SessionAccount_execute_from_outside_v3_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} SessionAccount_execute_from_outside_v3_result;
    SessionAccount_execute_from_outside_v3_result SessionAccount_execute_from_outside_v3(const diplomat::capi::SessionAccount* self, const diplomat::capi::DiplomatCallList* calls, diplomat::capi::DiplomatWrite* write);

    void SessionAccount_destroy(SessionAccount* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::unique_ptr<SessionAccount>, std::unique_ptr<ControllerError>> SessionAccount::new_as_registered(std::string_view rpc_url, const DiplomatFelt& signer, const DiplomatFelt& address, const DiplomatFelt& owner_guid, const DiplomatFelt& chain_id, const DiplomatPolicies& policies, uint64_t session_expiration) {
  auto result = diplomat::capi::SessionAccount_new_as_registered({rpc_url.data(), rpc_url.size()},
    signer.AsFFI(),
    address.AsFFI(),
    owner_guid.AsFFI(),
    chain_id.AsFFI(),
    policies.AsFFI(),
    session_expiration);
  return result.is_ok ? diplomat::result<std::unique_ptr<SessionAccount>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<SessionAccount>>(std::unique_ptr<SessionAccount>(SessionAccount::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<SessionAccount>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> SessionAccount::execute(const DiplomatCallList& calls) const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::SessionAccount_execute(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> SessionAccount::execute_write(const DiplomatCallList& calls, W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::SessionAccount_execute(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> SessionAccount::execute_from_outside_v3(const DiplomatCallList& calls) const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::SessionAccount_execute_from_outside_v3(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> SessionAccount::execute_from_outside_v3_write(const DiplomatCallList& calls, W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::SessionAccount_execute_from_outside_v3(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::SessionAccount* SessionAccount::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::SessionAccount*>(this);
}

inline diplomat::capi::SessionAccount* SessionAccount::AsFFI() {
  return reinterpret_cast<diplomat::capi::SessionAccount*>(this);
}

inline const SessionAccount* SessionAccount::FromFFI(const diplomat::capi::SessionAccount* ptr) {
  return reinterpret_cast<const SessionAccount*>(ptr);
}

inline SessionAccount* SessionAccount::FromFFI(diplomat::capi::SessionAccount* ptr) {
  return reinterpret_cast<SessionAccount*>(ptr);
}

inline void SessionAccount::operator delete(void* ptr) {
  diplomat::capi::SessionAccount_destroy(reinterpret_cast<diplomat::capi::SessionAccount*>(ptr));
}


#endif // SessionAccount_HPP
