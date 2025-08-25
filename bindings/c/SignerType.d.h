#ifndef SignerType_D_H
#define SignerType_D_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"





typedef enum SignerType {
  SignerType_Starknet = 0,
  SignerType_StarknetAccount = 1,
  SignerType_Eip191 = 2,
  SignerType_Webauthn = 3,
  SignerType_Siws = 4,
  SignerType_Secp256k1 = 5,
  SignerType_Secp256r1 = 6,
} SignerType;

typedef struct SignerType_option {union { SignerType ok; }; bool is_ok; } SignerType_option;



#endif // SignerType_D_H
