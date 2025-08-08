#include "diplomat_nanobind_common.hpp"


#include "DiplomatCall.hpp"


void add_DiplomatCall_binding(nb::handle mod) {
    PyType_Slot DiplomatCall_slots[] = {
        {Py_tp_free, (void *)DiplomatCall::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatCall>(mod, "DiplomatCall", nb::type_slots(DiplomatCall_slots))
    	.def_static("new", &DiplomatCall::new_, "to"_a, "selector"_a)
    	.def("push_calldata_bytes", &DiplomatCall::push_calldata_bytes, "byte"_a)
    	.def("push_calldata_str", &DiplomatCall::push_calldata_str, "felt"_a);
}

