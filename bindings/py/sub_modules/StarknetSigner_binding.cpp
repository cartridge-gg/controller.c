#include "diplomat_nanobind_common.hpp"


#include "StarknetSigner.hpp"


void add_StarknetSigner_binding(nb::handle mod) {
    PyType_Slot StarknetSigner_slots[] = {
        {Py_tp_free, (void *)StarknetSigner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<StarknetSigner>(mod, "StarknetSigner", nb::type_slots(StarknetSigner_slots));
}

