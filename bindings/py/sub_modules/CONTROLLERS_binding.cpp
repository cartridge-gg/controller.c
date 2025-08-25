#include "diplomat_nanobind_common.hpp"


#include "CONTROLLERS.hpp"


void add_CONTROLLERS_binding(nb::handle mod) {
    PyType_Slot CONTROLLERS_slots[] = {
        {Py_tp_free, (void *)CONTROLLERS::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<CONTROLLERS>(mod, "CONTROLLERS", nb::type_slots(CONTROLLERS_slots))
    	.def_static("get_class_hash", &CONTROLLERS::get_class_hash, "version"_a);
}

