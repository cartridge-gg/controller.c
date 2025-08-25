#include "diplomat_nanobind_common.hpp"


#include "DiplomatCallList.hpp"


void add_DiplomatCallList_binding(nb::handle mod) {
    PyType_Slot DiplomatCallList_slots[] = {
        {Py_tp_free, (void *)DiplomatCallList::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatCallList>(mod, "DiplomatCallList", nb::type_slots(DiplomatCallList_slots))
    	.def("add_call", &DiplomatCallList::add_call, "call"_a)
    	.def_static("new", &DiplomatCallList::new_);
}

