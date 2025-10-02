#ifndef DiplomatCall_H
#define DiplomatCall_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "DiplomatFelt.d.h"

#include "DiplomatCall.d.h"






DiplomatCall* DiplomatCall_new(DiplomatStringView to, DiplomatStringView selector);

void DiplomatCall_push_calldata_str(DiplomatCall* self, DiplomatStringView felt);

void DiplomatCall_push_calldata_bytes_be(DiplomatCall* self, DiplomatU8View byte);

void DiplomatCall_push_calldata(DiplomatCall* self, const DiplomatFelt* felt);

void DiplomatCall_destroy(DiplomatCall* self);





#endif // DiplomatCall_H
