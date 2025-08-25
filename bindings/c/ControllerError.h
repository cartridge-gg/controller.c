#ifndef ControllerError_H
#define ControllerError_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "ErrorType.d.h"

#include "ControllerError.d.h"






typedef struct ControllerError_message_result {union { ControllerError* err;}; bool is_ok;} ControllerError_message_result;
ControllerError_message_result ControllerError_message(const ControllerError* self, DiplomatWrite* write);

ErrorType ControllerError_error_type(const ControllerError* self);

void ControllerError_destroy(ControllerError* self);





#endif // ControllerError_H
