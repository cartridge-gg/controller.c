#include "../bindings/c/CONTROLLERS.h"
#include "../bindings/c/Controller.h"
#include "../bindings/c/ControllerError.h"
#include "../bindings/c/DiplomatCall.h"
#include "../bindings/c/DiplomatCallList.h"
#include "../bindings/c/DiplomatOwner.h"
#include "../bindings/c/diplomat_runtime.h"
#include <stdio.h>
#include <string.h>

int main() {

  const char *ETH_CONTRACT_ADDRESS =
      "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7";

  const char *app_id = "test_app";
  const char *username = "4";
  char buffer[256];
  DiplomatWrite writeable = diplomat_simple_write(buffer, sizeof(buffer));
  CONTROLLERS_get_class_hash_result class_hash_result =
      CONTROLLERS_get_class_hash(Version_LATEST, &writeable);
  if (class_hash_result.is_ok) {
    printf("Class hash: %s\n", buffer);
  } else {
    char error_buffer[512];
    DiplomatWrite error_writeable =
        diplomat_simple_write(error_buffer, sizeof(error_buffer));

    ControllerError_message(class_hash_result.err, &error_writeable);
    printf("📝 Error message: %.*s\n", (int)error_writeable.len, error_buffer);

    ControllerError_destroy(class_hash_result.err);

    return 1;
  }
  const char *rpc_url = "http://localhost:8001/x/starknet/mainnet";
  const char *address = "0x0";
  const char *chain_id = "0x534e5f4d41494e"; // SN_SEPOLIA
  // Test private key - DO NOT USE IN PRODUCTION
  const char *private_key =
      "0x1234567890123456789012345678901234567890123456789012345678901234";

  DiplomatStringView app_id_view = {app_id, strlen(app_id)};
  DiplomatStringView username_view = {username, strlen(username)};
  DiplomatStringView class_hash_view = {buffer, strlen(buffer)};
  DiplomatStringView rpc_url_view = {rpc_url, strlen(rpc_url)};
  DiplomatStringView chain_id_view = {chain_id, strlen(chain_id)};
  DiplomatStringView private_key_view = {private_key, strlen(private_key)};

  // Create owner from private key
  DiplomatOwner_new_from_starknet_signer_result owner_result =
      DiplomatOwner_new_from_starknet_signer(private_key_view);

  if (!owner_result.is_ok) {
    printf("❌ Failed to create owner from private key\n");
    if (owner_result.err) {
      char error_buffer[512];
      DiplomatWrite error_writeable =
          diplomat_simple_write(error_buffer, sizeof(error_buffer));
      ControllerError_message(owner_result.err, &error_writeable);
      printf("📝 Error message: %.*s\n", (int)error_writeable.len,
             error_buffer);
      ControllerError_destroy(owner_result.err);
      return 1;
    }
  }

  Controller_new_headless_result storage_result =
      Controller_new_headless(app_id_view, username_view, class_hash_view,
                              rpc_url_view, owner_result.ok, chain_id_view);

  if (storage_result.is_ok == false && storage_result.err) {
    char error_buffer[512];
    DiplomatWrite error_writeable =
        diplomat_simple_write(error_buffer, sizeof(error_buffer));

    ControllerError_message(storage_result.err, &error_writeable);
    printf("📝 Error message: %.*s\n", (int)error_writeable.len, error_buffer);

    ErrorType error_type = ControllerError_error_type(storage_result.err);
    printf("🏷️  Error type: %d\n", error_type);

    ControllerError_destroy(storage_result.err);
    return 1;
  }

  const Controller *controller = storage_result.ok;

  // Print address
  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  Controller_address(controller, &writeable);
  printf("📍 Controller address: %.*s\n", (int)writeable.len, buffer);

  // Print username
  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  Controller_username(controller, &writeable);
  printf("👤 Controller username: %.*s\n", (int)writeable.len, buffer);

  // Print app_id
  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  Controller_app_id(controller, &writeable);
  printf("🆔 Controller app_id: %.*s\n", (int)writeable.len, buffer);

  // Print chain_id
  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  Controller_chain_id(controller, &writeable);
  printf("⛓️  Controller chain_id: %.*s\n", (int)writeable.len, buffer);

  writeable = diplomat_simple_write(buffer, sizeof(buffer));

  Controller_address(controller, &writeable);
  printf("📍 Controller address: %.*s\n", (int)writeable.len, buffer);

  OptionU64 session_expiration = {.is_ok = true, .ok = 19999999999999};
  OptionStringView cartridge_api_url = {
      .is_ok = true,
      .ok = {.data = "http://localhost:8000",
             .len = strlen("http://localhost:8000")}};
  Controller_signup_result signup_result = Controller_signup(
      controller, SignerType_Starknet, session_expiration, cartridge_api_url);
  if (signup_result.is_ok == false && signup_result.err) {
    char error_buffer[512];
    DiplomatWrite error_writeable =
        diplomat_simple_write(error_buffer, sizeof(error_buffer));
    ControllerError_message(signup_result.err, &error_writeable);
    printf("📝 Error message: %.*s\n", (int)error_writeable.len, error_buffer);
    ControllerError_destroy(signup_result.err);
    return 1;
  } else {
    printf("✅ Signup successful\n");
  }

  DiplomatCallList *call_list = DiplomatCallList_new();
  DiplomatStringView eth_contract_address_view = {ETH_CONTRACT_ADDRESS,
                                                  strlen(ETH_CONTRACT_ADDRESS)};
  // transfer selector
  DiplomatStringView eth_contract_selector_view = {
      "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e",
      strlen(
          "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e")};
  DiplomatCall *call =
      DiplomatCall_new(eth_contract_address_view, eth_contract_selector_view);
  DiplomatStringView address_view = {buffer, (int)writeable.len};
  DiplomatStringView amount_view = {"0x0", strlen("0x0")};
  DiplomatStringView last_view = {"0x0", strlen("0x0")};
  DiplomatCall_push_calldata_str(call, address_view);
  DiplomatCall_push_calldata_str(call, amount_view);
  DiplomatCall_push_calldata_str(call, last_view);
  DiplomatCallList_add_call(call_list, call);

  writeable = diplomat_simple_write(buffer, sizeof(buffer));
  Controller_execute_result execute_result =
      Controller_execute(controller, call_list, &writeable);

  if (execute_result.is_ok == false && execute_result.err) {
    char error_buffer[512];
    DiplomatWrite error_writeable =
        diplomat_simple_write(error_buffer, sizeof(error_buffer));
    ControllerError_message(execute_result.err, &error_writeable);
    printf("📝 Error message: %.*s\n", (int)error_writeable.len, error_buffer);
    ControllerError_destroy(execute_result.err);
    return 1;
  }
  printf("📍 Transaction hash: %.*s\n", (int)writeable.len, buffer);

  Controller_destroy(storage_result.ok);

  // Clean up the owner
  if (owner_result.is_ok && owner_result.ok) {
    DiplomatOwner_destroy(owner_result.ok);
  }

  return 0;
}
