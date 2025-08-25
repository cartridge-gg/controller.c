#ifndef Version_D_H
#define Version_D_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"





typedef enum Version {
  Version_V1_0_4 = 0,
  Version_V1_0_5 = 1,
  Version_V1_0_6 = 2,
  Version_V1_0_7 = 3,
  Version_V1_0_8 = 4,
  Version_V1_0_9 = 5,
  Version_LATEST = 6,
} Version;

typedef struct Version_option {union { Version ok; }; bool is_ok; } Version_option;



#endif // Version_D_H
