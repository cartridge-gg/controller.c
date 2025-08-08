#ifndef Controller_HPP
#define Controller_HPP

#include "Controller.d.hpp"

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
#include "DiplomatOwner.hpp"
#include "SignerType.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    typedef struct Controller_new_result {union {diplomat::capi::Controller* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_new_result;
    Controller_new_result Controller_new(diplomat::capi::DiplomatStringView app_id, diplomat::capi::DiplomatStringView username, diplomat::capi::DiplomatStringView class_hash, diplomat::capi::DiplomatStringView rpc_url, const diplomat::capi::DiplomatOwner* owner, diplomat::capi::DiplomatStringView address, diplomat::capi::DiplomatStringView chain_id);

    typedef struct Controller_new_headless_result {union {diplomat::capi::Controller* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_new_headless_result;
    Controller_new_headless_result Controller_new_headless(diplomat::capi::DiplomatStringView app_id, diplomat::capi::DiplomatStringView username, diplomat::capi::DiplomatStringView class_hash, diplomat::capi::DiplomatStringView rpc_url, const diplomat::capi::DiplomatOwner* owner, diplomat::capi::DiplomatStringView chain_id);

    typedef struct Controller_from_storage_result {union {diplomat::capi::Controller* ok; diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_from_storage_result;
    Controller_from_storage_result Controller_from_storage(diplomat::capi::DiplomatStringView app_id);

    typedef struct Controller_signup_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_signup_result;
    Controller_signup_result Controller_signup(const diplomat::capi::Controller* self, diplomat::capi::SignerType signer_type, diplomat::capi::OptionU64 session_expiration, diplomat::capi::OptionStringView cartridge_api_url);

    typedef struct Controller_address_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_address_result;
    Controller_address_result Controller_address(const diplomat::capi::Controller* self, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_username_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_username_result;
    Controller_username_result Controller_username(const diplomat::capi::Controller* self, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_app_id_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_app_id_result;
    Controller_app_id_result Controller_app_id(const diplomat::capi::Controller* self, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_chain_id_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_chain_id_result;
    Controller_chain_id_result Controller_chain_id(const diplomat::capi::Controller* self, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_disconnect_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_disconnect_result;
    Controller_disconnect_result Controller_disconnect(const diplomat::capi::Controller* self);

    typedef struct Controller_execute_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_execute_result;
    Controller_execute_result Controller_execute(const diplomat::capi::Controller* self, const diplomat::capi::DiplomatCallList* calls, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_delegate_account_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_delegate_account_result;
    Controller_delegate_account_result Controller_delegate_account(const diplomat::capi::Controller* self, diplomat::capi::DiplomatWrite* write);

    typedef struct Controller_transfer_result {union { diplomat::capi::ControllerError* err;}; bool is_ok;} Controller_transfer_result;
    Controller_transfer_result Controller_transfer(const diplomat::capi::Controller* self, diplomat::capi::DiplomatStringView recipient, diplomat::capi::DiplomatStringView amount, diplomat::capi::DiplomatWrite* write);

    void Controller_destroy(Controller* self);

    } // extern "C"
} // namespace capi
} // namespace

inline diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> Controller::new_(std::string_view app_id, std::string_view username, std::string_view class_hash, std::string_view rpc_url, const DiplomatOwner& owner, std::string_view address, std::string_view chain_id) {
  auto result = diplomat::capi::Controller_new({app_id.data(), app_id.size()},
    {username.data(), username.size()},
    {class_hash.data(), class_hash.size()},
    {rpc_url.data(), rpc_url.size()},
    owner.AsFFI(),
    {address.data(), address.size()},
    {chain_id.data(), chain_id.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<Controller>>(std::unique_ptr<Controller>(Controller::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> Controller::new_headless(std::string_view app_id, std::string_view username, std::string_view class_hash, std::string_view rpc_url, const DiplomatOwner& owner, std::string_view chain_id) {
  auto result = diplomat::capi::Controller_new_headless({app_id.data(), app_id.size()},
    {username.data(), username.size()},
    {class_hash.data(), class_hash.size()},
    {rpc_url.data(), rpc_url.size()},
    owner.AsFFI(),
    {chain_id.data(), chain_id.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<Controller>>(std::unique_ptr<Controller>(Controller::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> Controller::from_storage(std::string_view app_id) {
  auto result = diplomat::capi::Controller_from_storage({app_id.data(), app_id.size()});
  return result.is_ok ? diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Ok<std::unique_ptr<Controller>>(std::unique_ptr<Controller>(Controller::FromFFI(result.ok)))) : diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::signup(SignerType signer_type, std::optional<uint64_t> session_expiration, std::optional<std::string_view> cartridge_api_url) const {
  auto result = diplomat::capi::Controller_signup(this->AsFFI(),
    signer_type.AsFFI(),
    session_expiration.has_value() ? (diplomat::capi::OptionU64{ { session_expiration.value() }, true }) : (diplomat::capi::OptionU64{ {}, false }),
    cartridge_api_url.has_value() ? (diplomat::capi::OptionStringView{ { {cartridge_api_url.value().data(), cartridge_api_url.value().size()} }, true }) : (diplomat::capi::OptionStringView{ {}, false }));
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::address() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_address(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::address_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_address(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::username() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_username(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::username_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_username(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::app_id() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_app_id(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::app_id_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_app_id(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::chain_id() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_chain_id(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::chain_id_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_chain_id(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::disconnect() const {
  auto result = diplomat::capi::Controller_disconnect(this->AsFFI());
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::execute(const DiplomatCallList& calls) const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_execute(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::execute_write(const DiplomatCallList& calls, W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_execute(this->AsFFI(),
    calls.AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::delegate_account() const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_delegate_account(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::delegate_account_write(W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_delegate_account(this->AsFFI(),
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline diplomat::result<std::string, std::unique_ptr<ControllerError>> Controller::transfer(std::string_view recipient, std::string_view amount) const {
  std::string output;
  diplomat::capi::DiplomatWrite write = diplomat::WriteFromString(output);
  auto result = diplomat::capi::Controller_transfer(this->AsFFI(),
    {recipient.data(), recipient.size()},
    {amount.data(), amount.size()},
    &write);
  return result.is_ok ? diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Ok<std::string>(std::move(output))) : diplomat::result<std::string, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}
template<typename W>
inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> Controller::transfer_write(std::string_view recipient, std::string_view amount, W& writeable) const {
  diplomat::capi::DiplomatWrite write = diplomat::WriteTrait<W>::Construct(writeable);
  auto result = diplomat::capi::Controller_transfer(this->AsFFI(),
    {recipient.data(), recipient.size()},
    {amount.data(), amount.size()},
    &write);
  return result.is_ok ? diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Ok<std::monostate>()) : diplomat::result<std::monostate, std::unique_ptr<ControllerError>>(diplomat::Err<std::unique_ptr<ControllerError>>(std::unique_ptr<ControllerError>(ControllerError::FromFFI(result.err))));
}

inline const diplomat::capi::Controller* Controller::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::Controller*>(this);
}

inline diplomat::capi::Controller* Controller::AsFFI() {
  return reinterpret_cast<diplomat::capi::Controller*>(this);
}

inline const Controller* Controller::FromFFI(const diplomat::capi::Controller* ptr) {
  return reinterpret_cast<const Controller*>(ptr);
}

inline Controller* Controller::FromFFI(diplomat::capi::Controller* ptr) {
  return reinterpret_cast<Controller*>(ptr);
}

inline void Controller::operator delete(void* ptr) {
  diplomat::capi::Controller_destroy(reinterpret_cast<diplomat::capi::Controller*>(ptr));
}


#endif // Controller_HPP
