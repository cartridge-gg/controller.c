#ifndef DiplomatSigner_H
#define DiplomatSigner_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "diplomat_runtime.h"

#include "DiplomatFelt.d.h"

#include "DiplomatSigner.d.h"






DiplomatSigner* DiplomatSigner_new_starknet_signer(const DiplomatFelt* secret_scalar);

void DiplomatSigner_destroy(DiplomatSigner* self);





#endif // DiplomatSigner_H
