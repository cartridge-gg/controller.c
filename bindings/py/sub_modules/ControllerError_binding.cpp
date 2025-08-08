#include "diplomat_nanobind_common.hpp"


#include "ControllerError.hpp"


void add_ControllerError_binding(nb::handle mod) {
    PyType_Slot ControllerError_slots[] = {
        {Py_tp_free, (void *)ControllerError::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ControllerError>(mod, "ControllerError", nb::type_slots(ControllerError_slots))
    	.def("error_type", &ControllerError::error_type)
    	.def("message", &ControllerError::message);
}

