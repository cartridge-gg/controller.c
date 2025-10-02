#ifndef DiplomatPolicies_H
#define DiplomatPolicies_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "DiplomatFelt.d.h"

#include "DiplomatPolicies.d.h"






DiplomatPolicies* DiplomatPolicies_new(void);

void DiplomatPolicies_add_call(DiplomatPolicies* self, const DiplomatFelt* contract_address, const DiplomatFelt* selector);

void DiplomatPolicies_add_typed_data(DiplomatPolicies* self, const DiplomatFelt* scope_hash);

void DiplomatPolicies_destroy(DiplomatPolicies* self);





#endif // DiplomatPolicies_H
