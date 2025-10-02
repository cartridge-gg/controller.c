#include "diplomat_nanobind_common.hpp"


#include "ResponseDataOut.hpp"


void add_ResponseDataOut_binding(nb::handle mod) {
    PyType_Slot ResponseDataOut_slots[] = {
        {Py_tp_free, (void *)ResponseDataOut::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ResponseDataOut>(mod, "ResponseDataOut", nb::type_slots(ResponseDataOut_slots));
}

