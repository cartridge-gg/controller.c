#ifndef SessionAccount_D_HPP
#define SessionAccount_D_HPP

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
namespace diplomat::capi { struct DiplomatFelt; }
class DiplomatFelt;
namespace diplomat::capi { struct DiplomatPolicies; }
class DiplomatPolicies;


namespace diplomat {
namespace capi {
    struct SessionAccount;
} // namespace capi
} // namespace

/**
 * Opaque handle to a Controller instance
 */
class SessionAccount {
public:

  /**
   * Creates a new Controller instance
   */
  inline static diplomat::result<std::unique_ptr<SessionAccount>, std::unique_ptr<ControllerError>> new_as_registered(std::string_view rpc_url, const DiplomatFelt& signer, const DiplomatFelt& address, const DiplomatFelt& owner_guid, const DiplomatFelt& chain_id, const DiplomatPolicies& policies, uint64_t session_expiration);

  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> execute(const DiplomatCallList& calls) const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> execute_write(const DiplomatCallList& calls, W& writeable_output) const;

  inline diplomat::result<std::string, std::unique_ptr<ControllerError>> execute_from_outside_v3(const DiplomatCallList& calls) const;
  template<typename W>
  inline diplomat::result<std::monostate, std::unique_ptr<ControllerError>> execute_from_outside_v3_write(const DiplomatCallList& calls, W& writeable_output) const;

  inline const diplomat::capi::SessionAccount* AsFFI() const;
  inline diplomat::capi::SessionAccount* AsFFI();
  inline static const SessionAccount* FromFFI(const diplomat::capi::SessionAccount* ptr);
  inline static SessionAccount* FromFFI(diplomat::capi::SessionAccount* ptr);
  inline static void operator delete(void* ptr);
private:
  SessionAccount() = delete;
  SessionAccount(const SessionAccount&) = delete;
  SessionAccount(SessionAccount&&) noexcept = delete;
  SessionAccount operator=(const SessionAccount&) = delete;
  SessionAccount operator=(SessionAccount&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // SessionAccount_D_HPP
