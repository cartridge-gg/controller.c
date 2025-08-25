#include "diplomat_nanobind_common.hpp"


#include "ControllerWithRuntime.hpp"


void add_ControllerWithRuntime_binding(nb::handle mod) {
    PyType_Slot ControllerWithRuntime_slots[] = {
        {Py_tp_free, (void *)ControllerWithRuntime::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ControllerWithRuntime>(mod, "ControllerWithRuntime", nb::type_slots(ControllerWithRuntime_slots));
}

