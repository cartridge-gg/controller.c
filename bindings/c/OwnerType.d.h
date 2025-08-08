#ifndef OwnerType_D_H
#define OwnerType_D_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"





typedef enum OwnerType {
  OwnerType_Signer = 0,
  OwnerType_Account = 1,
} OwnerType;

typedef struct OwnerType_option {union { OwnerType ok; }; bool is_ok; } OwnerType_option;



#endif // OwnerType_D_H
