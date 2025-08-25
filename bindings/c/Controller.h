#ifndef Controller_H
#define Controller_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"
#include "DiplomatCallList.d.h"
#include "DiplomatOwner.d.h"
#include "SignerType.d.h"

#include "Controller.d.h"






typedef struct Controller_new_result {union {Controller* ok; ControllerError* err;}; bool is_ok;} Controller_new_result;
Controller_new_result Controller_new(DiplomatStringView app_id, DiplomatStringView username, DiplomatStringView class_hash, DiplomatStringView rpc_url, const DiplomatOwner* owner, DiplomatStringView address, DiplomatStringView chain_id);

typedef struct Controller_new_headless_result {union {Controller* ok; ControllerError* err;}; bool is_ok;} Controller_new_headless_result;
Controller_new_headless_result Controller_new_headless(DiplomatStringView app_id, DiplomatStringView username, DiplomatStringView class_hash, DiplomatStringView rpc_url, const DiplomatOwner* owner, DiplomatStringView chain_id);

typedef struct Controller_from_storage_result {union {Controller* ok; ControllerError* err;}; bool is_ok;} Controller_from_storage_result;
Controller_from_storage_result Controller_from_storage(DiplomatStringView app_id);

typedef struct Controller_signup_result {union { ControllerError* err;}; bool is_ok;} Controller_signup_result;
Controller_signup_result Controller_signup(const Controller* self, SignerType signer_type, OptionU64 session_expiration, OptionStringView cartridge_api_url);

typedef struct Controller_address_result {union { ControllerError* err;}; bool is_ok;} Controller_address_result;
Controller_address_result Controller_address(const Controller* self, DiplomatWrite* write);

typedef struct Controller_username_result {union { ControllerError* err;}; bool is_ok;} Controller_username_result;
Controller_username_result Controller_username(const Controller* self, DiplomatWrite* write);

typedef struct Controller_app_id_result {union { ControllerError* err;}; bool is_ok;} Controller_app_id_result;
Controller_app_id_result Controller_app_id(const Controller* self, DiplomatWrite* write);

typedef struct Controller_chain_id_result {union { ControllerError* err;}; bool is_ok;} Controller_chain_id_result;
Controller_chain_id_result Controller_chain_id(const Controller* self, DiplomatWrite* write);

typedef struct Controller_disconnect_result {union { ControllerError* err;}; bool is_ok;} Controller_disconnect_result;
Controller_disconnect_result Controller_disconnect(const Controller* self);

typedef struct Controller_execute_result {union { ControllerError* err;}; bool is_ok;} Controller_execute_result;
Controller_execute_result Controller_execute(const Controller* self, const DiplomatCallList* calls, DiplomatWrite* write);

typedef struct Controller_delegate_account_result {union { ControllerError* err;}; bool is_ok;} Controller_delegate_account_result;
Controller_delegate_account_result Controller_delegate_account(const Controller* self, DiplomatWrite* write);

typedef struct Controller_transfer_result {union { ControllerError* err;}; bool is_ok;} Controller_transfer_result;
Controller_transfer_result Controller_transfer(const Controller* self, DiplomatStringView recipient, DiplomatStringView amount, DiplomatWrite* write);

void Controller_destroy(Controller* self);





#endif // Controller_H
