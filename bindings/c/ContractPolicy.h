#ifndef ContractPolicy_H
#define ContractPolicy_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "Method.d.h"

#include "ContractPolicy.d.h"






ContractPolicy* ContractPolicy_new(OptionStringView name, OptionStringView description);

void ContractPolicy_push_method(ContractPolicy* self, const Method* method);

void ContractPolicy_destroy(ContractPolicy* self);





#endif // ContractPolicy_H
