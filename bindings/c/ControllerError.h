#ifndef ControllerError_H
#define ControllerError_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"


#include "ControllerError.d.h"






typedef struct ControllerError_message_result {union { ControllerError* err;}; bool is_ok;} ControllerError_message_result;
ControllerError_message_result ControllerError_message(const ControllerError* self, DiplomatWrite* write);

void ControllerError_get_message_string(const ControllerError* self, DiplomatWrite* write);

void ControllerError_get_last_error_message(DiplomatWrite* write);

void ControllerError_clear_last_error(void);

void ControllerError_destroy(ControllerError* self);





#endif // ControllerError_H
