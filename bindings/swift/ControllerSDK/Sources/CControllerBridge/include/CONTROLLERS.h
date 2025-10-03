#ifndef CONTROLLERS_H
#define CONTROLLERS_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ControllerError.d.h"
#include "Version.d.h"

#include "CONTROLLERS.d.h"






typedef struct CONTROLLERS_get_class_hash_result {union { ControllerError* err;}; bool is_ok;} CONTROLLERS_get_class_hash_result;
CONTROLLERS_get_class_hash_result CONTROLLERS_get_class_hash(Version version, DiplomatWrite* write);

void CONTROLLERS_destroy(CONTROLLERS* self);





#endif // CONTROLLERS_H
