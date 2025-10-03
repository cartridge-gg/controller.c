#ifndef DiplomatOwner_H
#define DiplomatOwner_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"

#include "DiplomatOwner.d.h"






typedef struct DiplomatOwner_new_from_starknet_signer_result {union {DiplomatOwner* ok; ControllerError* err;}; bool is_ok;} DiplomatOwner_new_from_starknet_signer_result;
DiplomatOwner_new_from_starknet_signer_result DiplomatOwner_new_from_starknet_signer(DiplomatStringView starknet_pk);

void DiplomatOwner_destroy(DiplomatOwner* self);





#endif // DiplomatOwner_H
