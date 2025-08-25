#include "diplomat_nanobind_common.hpp"


#include "ErrorUtils.hpp"


void add_ErrorUtils_binding(nb::handle mod) {
    PyType_Slot ErrorUtils_slots[] = {
        {Py_tp_free, (void *)ErrorUtils::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ErrorUtils>(mod, "ErrorUtils", nb::type_slots(ErrorUtils_slots))
    	.def_static("clear_last_error", &ErrorUtils::clear_last_error)
    	.def_static("get_last_error_message", &ErrorUtils::get_last_error_message);
}

