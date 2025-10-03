#ifndef DiplomatSessionPolicies_H
#define DiplomatSessionPolicies_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ContractPolicy.d.h"
#include "SignMessagePolicy.d.h"

#include "DiplomatSessionPolicies.d.h"






DiplomatSessionPolicies* DiplomatSessionPolicies_new(void);

void DiplomatSessionPolicies_add_contract_policy(DiplomatSessionPolicies* self, DiplomatStringView address, const ContractPolicy* policy);

void DiplomatSessionPolicies_add_message_policy(DiplomatSessionPolicies* self, const SignMessagePolicy* policy);

void DiplomatSessionPolicies_to_url_string(const DiplomatSessionPolicies* self, DiplomatWrite* write);

void DiplomatSessionPolicies_destroy(DiplomatSessionPolicies* self);





#endif // DiplomatSessionPolicies_H
