#include "diplomat_nanobind_common.hpp"


#include "DiplomatSigner.hpp"


void add_DiplomatSigner_binding(nb::handle mod) {
    PyType_Slot DiplomatSigner_slots[] = {
        {Py_tp_free, (void *)DiplomatSigner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatSigner>(mod, "DiplomatSigner", nb::type_slots(DiplomatSigner_slots));
}

