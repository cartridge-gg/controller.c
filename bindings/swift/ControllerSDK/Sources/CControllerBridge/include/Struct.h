#ifndef Struct_H
#define Struct_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"


#include "Struct.d.h"






void Struct_bar(DiplomatStructViewMut slice);

void Struct_baz(DiplomatStructView other_slice);





#endif // Struct_H
