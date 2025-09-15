#include "diplomat_nanobind_common.hpp"


#include "SessionAccountInner.hpp"


void add_SessionAccountInner_binding(nb::handle mod) {
    PyType_Slot SessionAccountInner_slots[] = {
        {Py_tp_free, (void *)SessionAccountInner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<SessionAccountInner>(mod, "SessionAccountInner", nb::type_slots(SessionAccountInner_slots));
}

