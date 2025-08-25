#ifndef ErrorType_D_H
#define ErrorType_D_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"





typedef enum ErrorType {
  ErrorType_InitError = 0,
  ErrorType_RuntimeError = 1,
  ErrorType_SessionError = 2,
  ErrorType_InvalidInput = 3,
  ErrorType_NotDeployed = 4,
  ErrorType_InsufficientBalance = 5,
} ErrorType;

typedef struct ErrorType_option {union { ErrorType ok; }; bool is_ok; } ErrorType_option;



#endif // ErrorType_D_H
