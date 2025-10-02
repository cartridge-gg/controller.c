#include "diplomat_nanobind_common.hpp"


#include "DiplomatPolicies.hpp"


void add_DiplomatPolicies_binding(nb::handle mod) {
    PyType_Slot DiplomatPolicies_slots[] = {
        {Py_tp_free, (void *)DiplomatPolicies::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatPolicies>(mod, "DiplomatPolicies", nb::type_slots(DiplomatPolicies_slots))
    	.def("add_call", &DiplomatPolicies::add_call, "contract_address"_a, "selector"_a)
    	.def("add_typed_data", &DiplomatPolicies::add_typed_data, "scope_hash"_a)
    	.def_static("new", &DiplomatPolicies::new_);
}

