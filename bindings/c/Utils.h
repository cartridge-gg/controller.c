#ifndef Utils_H
#define Utils_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"
#include "DiplomatFelt.d.h"
#include "DiplomatSigner.d.h"
#include "ResponseDataOut.d.h"

#include "Utils.d.h"






typedef struct Utils_subscribe_create_session_result {union {ResponseDataOut* ok; ControllerError* err;}; bool is_ok;} Utils_subscribe_create_session_result;
Utils_subscribe_create_session_result Utils_subscribe_create_session(const DiplomatFelt* session_key_guid, DiplomatStringView cartridge_api_url);

DiplomatFelt* Utils_signer_to_guid(const DiplomatSigner* signer);

DiplomatFelt* Utils_get_public_key(const DiplomatFelt* private_key);

void Utils_destroy(Utils* self);





#endif // Utils_H
