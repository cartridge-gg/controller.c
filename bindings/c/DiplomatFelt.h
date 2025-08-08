#ifndef DiplomatFelt_H
#define DiplomatFelt_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"

#include "DiplomatFelt.d.h"






typedef struct DiplomatFelt_new_from_hex_result {union {DiplomatFelt* ok; ControllerError* err;}; bool is_ok;} DiplomatFelt_new_from_hex_result;
DiplomatFelt_new_from_hex_result DiplomatFelt_new_from_hex(DiplomatStringView hex);

typedef struct DiplomatFelt_new_from_bytes_result {union {DiplomatFelt* ok; ControllerError* err;}; bool is_ok;} DiplomatFelt_new_from_bytes_result;
DiplomatFelt_new_from_bytes_result DiplomatFelt_new_from_bytes(DiplomatU8View bytes);

void DiplomatFelt_destroy(DiplomatFelt* self);





#endif // DiplomatFelt_H
