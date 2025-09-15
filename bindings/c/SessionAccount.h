#ifndef SessionAccount_H
#define SessionAccount_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"
#include "DiplomatCallList.d.h"
#include "DiplomatFelt.d.h"
#include "DiplomatPolicies.d.h"

#include "SessionAccount.d.h"






typedef struct SessionAccount_new_as_registered_result {union {SessionAccount* ok; ControllerError* err;}; bool is_ok;} SessionAccount_new_as_registered_result;
SessionAccount_new_as_registered_result SessionAccount_new_as_registered(DiplomatStringView rpc_url, const DiplomatFelt* signer, const DiplomatFelt* address, const DiplomatFelt* owner_guid, const DiplomatFelt* chain_id, const DiplomatPolicies* policies, uint64_t session_expiration);

typedef struct SessionAccount_execute_result {union { ControllerError* err;}; bool is_ok;} SessionAccount_execute_result;
SessionAccount_execute_result SessionAccount_execute(const SessionAccount* self, const DiplomatCallList* calls, DiplomatWrite* write);

typedef struct SessionAccount_execute_from_outside_v3_result {union { ControllerError* err;}; bool is_ok;} SessionAccount_execute_from_outside_v3_result;
SessionAccount_execute_from_outside_v3_result SessionAccount_execute_from_outside_v3(const SessionAccount* self, const DiplomatCallList* calls, DiplomatWrite* write);

void SessionAccount_destroy(SessionAccount* self);





#endif // SessionAccount_H
