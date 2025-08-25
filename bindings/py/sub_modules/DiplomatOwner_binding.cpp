#include "diplomat_nanobind_common.hpp"


#include "DiplomatOwner.hpp"


void add_DiplomatOwner_binding(nb::handle mod) {
    PyType_Slot DiplomatOwner_slots[] = {
        {Py_tp_free, (void *)DiplomatOwner::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatOwner>(mod, "DiplomatOwner", nb::type_slots(DiplomatOwner_slots))
    	.def_static("new_from_starknet_signer", &DiplomatOwner::new_from_starknet_signer, "starknet_pk"_a);
}

