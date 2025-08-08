#ifndef DiplomatCallList_H
#define DiplomatCallList_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "DiplomatCall.d.h"

#include "DiplomatCallList.d.h"






DiplomatCallList* DiplomatCallList_new(void);

void DiplomatCallList_add_call(DiplomatCallList* self, const DiplomatCall* call);

void DiplomatCallList_destroy(DiplomatCallList* self);





#endif // DiplomatCallList_H
