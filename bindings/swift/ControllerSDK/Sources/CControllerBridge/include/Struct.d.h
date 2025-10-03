#ifndef Struct_D_H
#define Struct_D_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"





typedef struct Struct {
  bool a;
  int32_t b;
} Struct;

typedef struct Struct_option {union { Struct ok; }; bool is_ok; } Struct_option;
typedef struct DiplomatStructView {
  const Struct* data;
  size_t len;
} DiplomatStructView;

typedef struct DiplomatStructViewMut {
  Struct* data;
  size_t len;
} DiplomatStructViewMut;




#endif // Struct_D_H
