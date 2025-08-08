#include "diplomat_nanobind_common.hpp"


#include "DiplomatFelt.hpp"


void add_DiplomatFelt_binding(nb::handle mod) {
    PyType_Slot DiplomatFelt_slots[] = {
        {Py_tp_free, (void *)DiplomatFelt::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatFelt>(mod, "DiplomatFelt", nb::type_slots(DiplomatFelt_slots))
    	.def_static("new_from_bytes", &DiplomatFelt::new_from_bytes, "bytes"_a)
    	.def_static("new_from_hex", &DiplomatFelt::new_from_hex, "hex"_a);
}

