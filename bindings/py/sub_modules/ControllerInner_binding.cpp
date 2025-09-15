#include "diplomat_nanobind_common.hpp"


#include "ControllerInner.hpp"


void add_ControllerInner_binding(nb::handle mod) {
    PyType_Slot ControllerInner_slots[] = {
        {Py_tp_free, (void *)ControllerInner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ControllerInner>(mod, "ControllerInner", nb::type_slots(ControllerInner_slots));
}

