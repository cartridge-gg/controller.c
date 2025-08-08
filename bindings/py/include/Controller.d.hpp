#ifndef Controller_D_HPP
#define Controller_D_HPP

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
namespace diplomat::capi { struct DiplomatCallList; }
class DiplomatCallList;
namespace diplomat::capi { struct DiplomatOwner; }
class DiplomatOwner;
class SignerType;


namespace diplomat {
namespace capi {
    struct Controller;
} // namespace capi
} // namespace

/**
 * Opaque handle to a Controller instance
 */
class Controller {
public:

  /**
   * Creates a new Controller instance
   */
  inline static diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> new_(std::string_view app_id, std::string_view username, std::string_view class_hash, std::string_view rpc_url, const DiplomatOwner& owner, std::string_view address, std::string_view chain_id);

  /**
   * Creates a new Controller headless instance
   */
  inline static diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> new_headless(std::string_view app_id, std::string_view username, std::string_view class_hash, std::string_view rpc_url, const DiplomatOwner& owner, std::string_view chain_id);

  /**
   * Creates a Controller from storage
   */
  inline static diplomat::result<std::unique_ptr<Controller>, std::unique_ptr<ControllerError>> from_storage(std::string_view app_id);

  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> signup(SignerType signer_type, std::optional<uint64_t> session_expiration, std::optional<std::string_view> cartridge_api_url) const;

  /**
   * Gets the controller's address
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> address() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> address_write(W& writeable_output) const;

  /**
   * Gets the controller's username
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> username() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> username_write(W& writeable_output) const;

  /**
   * Gets the controller's app ID
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> app_id() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> app_id_write(W& writeable_output) const;

  /**
   * Gets the controller's chain ID
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> chain_id() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> chain_id_write(W& writeable_output) const;

  /**
   * Disconnects the controller and clears storage
   */
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> disconnect() const;

  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> execute(const DiplomatCallList& calls) const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> execute_write(const DiplomatCallList& calls, W& writeable_output) const;

  /**
   * Gets the delegate account address
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> delegate_account() const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> delegate_account_write(W& writeable_output) const;

  /**
   * Execute a simple transfer
   */
  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> transfer(std::string_view recipient, std::string_view amount) const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> transfer_write(std::string_view recipient, std::string_view amount, W& writeable_output) const;

  inline const diplomat::capi::Controller* AsFFI() const;
  inline diplomat::capi::Controller* AsFFI();
  inline static const Controller* FromFFI(const diplomat::capi::Controller* ptr);
  inline static Controller* FromFFI(diplomat::capi::Controller* ptr);
  inline static void operator delete(void* ptr);
private:
  Controller() = delete;
  Controller(const Controller&) = delete;
  Controller(Controller&&) noexcept = delete;
  Controller operator=(const Controller&) = delete;
  Controller operator=(Controller&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // Controller_D_HPP
