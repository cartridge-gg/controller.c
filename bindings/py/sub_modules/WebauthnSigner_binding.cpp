#include "diplomat_nanobind_common.hpp"


#include "WebauthnSigner.hpp"


void add_WebauthnSigner_binding(nb::handle mod) {
    PyType_Slot WebauthnSigner_slots[] = {
        {Py_tp_free, (void *)WebauthnSigner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<WebauthnSigner>(mod, "WebauthnSigner", nb::type_slots(WebauthnSigner_slots));
}

