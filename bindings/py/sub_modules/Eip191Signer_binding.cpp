#include "diplomat_nanobind_common.hpp"


#include "Eip191Signer.hpp"


void add_Eip191Signer_binding(nb::handle mod) {
    PyType_Slot Eip191Signer_slots[] = {
        {Py_tp_free, (void *)Eip191Signer::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<Eip191Signer>(mod, "Eip191Signer", nb::type_slots(Eip191Signer_slots));
}

