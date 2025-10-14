#include "../bindings/c/ContractPolicy.h"
#include "../bindings/c/ControllerError.h"
#include "../bindings/c/DiplomatFelt.h"
#include "../bindings/c/DiplomatOwner.h"
#include "../bindings/c/DiplomatSessionPolicies.h"
#include "../bindings/c/DiplomatSigner.h"
#include "../bindings/c/Method.h"
#include "../bindings/c/SessionAccount.h"
#include "../bindings/c/Utils.h"
#include "../bindings/c/diplomat_runtime.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>

OptionStringView noneStringViewOption() {
  return (OptionStringView){.ok = NULL, .is_ok = false};
}

DiplomatStringView toStringView(const char *string) {
  return (DiplomatStringView){string, strlen(string)};
}

OptionStringView toOptionStringView(const char *string) {
  return (OptionStringView){.ok = (DiplomatStringView){string, strlen(string)},
                            .is_ok = true};
}

const char *RPC_URL = "https://api.cartridge.gg/x/starknet/mainnet";
const char *CARTRIDGE_API_URL = "https://api.cartridge.gg";
const char *KEYCHAIN_URL = "https://x.cartridge.gg";

int main() {
  char buffer[1024];
  DiplomatWrite writeable = diplomat_simple_write(buffer, sizeof(buffer));

  // Test private key - DO NOT USE IN PRODUCTION
  DiplomatStringView private_key_view = toStringView(
      "0x123456789012345678901234567890123456789012345678901234567890abcd");
  DiplomatFelt_new_from_hex_result pk =
      DiplomatFelt_new_from_hex(private_key_view);
  if (!pk.is_ok) {
    printf("Failed to create PK\n");
    return 1;
  }

  // Build policies
  DiplomatSessionPolicies *session_policies = DiplomatSessionPolicies_new();

  ContractPolicy *policy =
      ContractPolicy_new(noneStringViewOption(), noneStringViewOption());
  Method *method =
      Method_new(toStringView("transfer"),
                 toStringView("transfer funds from one account to the other"),
                 toStringView("transfer"), true, true, true);
  ContractPolicy_push_method(policy, method);

  DiplomatSessionPolicies_add_contract_policy(
      session_policies,
      toStringView(
          "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"),
      policy);

  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  DiplomatSessionPolicies_to_url_string(session_policies, &writeable);

  char policies[1024];
  memcpy(policies, buffer, (int)writeable.len);
  policies[writeable.len] = 0;

  DiplomatFelt *public_key = Utils_get_public_key(pk.ok);

  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  DiplomatFelt_to_hex_string(public_key, &writeable);

  // Link the session to the Controller account via the browser
  printf("\nPlease open a browser to this URL and create a session:\n\n"
         "%s/session"
         "?public_key=%.*s"
         "&policies=%s"
         "&rpc_url=%s"
         "&redirect_uri=https://docs.cartridge.gg/controller/overview"
         "&redirect_query_name=startapp\n\n",
         KEYCHAIN_URL, (int)writeable.len, buffer, policies, RPC_URL);

  printf("\nPress enter to continue when the session is created...\n");
  getchar();

  DiplomatSigner *starknet_signer = DiplomatSigner_new_starknet_signer(pk.ok);
  DiplomatFelt *guid = Utils_signer_to_guid(starknet_signer);
  writeable = diplomat_simple_write(buffer, sizeof(buffer));

  DiplomatFelt_to_hex_string(guid, &writeable);

  // Create owner from private key
  DiplomatOwner_new_from_starknet_signer_result owner_result =
      DiplomatOwner_new_from_starknet_signer(private_key_view);

  SessionAccount_create_from_subscribe_create_session_result ret =
      SessionAccount_create_from_subscribe_create_session(
          starknet_signer, session_policies,
          toStringView(RPC_URL), toStringView(CARTRIDGE_API_URL));

  if (!ret.is_ok) {
    printf("❌ Failed to get ret\n");
    if (ret.err) {
      char error_buffer[512];
      DiplomatWrite error_writeable =
          diplomat_simple_write(error_buffer, sizeof(error_buffer));
      ControllerError_message(ret.err, &error_writeable);
      printf("📝 Error message: %.*s\n", (int)error_writeable.len,
             error_buffer);
      ControllerError_destroy(ret.err);
      return 1;
    }
  }

  return 0;
}
