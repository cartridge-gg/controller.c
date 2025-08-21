#include "diplomat_nanobind_common.hpp"


#include "ControllerError.hpp"


void add_ControllerError_binding(nb::handle mod) {
    PyType_Slot ControllerError_slots[] = {
        {Py_tp_free, (void *)ControllerError::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ControllerError>(mod, "ControllerError", nb::type_slots(ControllerError_slots))
    	.def_static("clear_last_error", &ControllerError::clear_last_error)
    	.def_static("get_last_error_message", &ControllerError::get_last_error_message)
    	.def("get_message_string", &ControllerError::get_message_string)
    	.def("message", &ControllerError::message);
}

