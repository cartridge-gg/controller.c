#ifndef Method_H
#define Method_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"


#include "Method.d.h"






Method* Method_new(DiplomatStringView name, DiplomatStringView description, DiplomatStringView entrypoint, bool is_enabled, bool is_required, bool is_paymastered);

void Method_destroy(Method* self);





#endif // Method_H
