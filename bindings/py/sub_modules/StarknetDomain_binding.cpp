#include "diplomat_nanobind_common.hpp"


#include "StarknetDomain.hpp"


void add_StarknetDomain_binding(nb::handle mod) {
    PyType_Slot StarknetDomain_slots[] = {
        {Py_tp_free, (void *)StarknetDomain::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<StarknetDomain>(mod, "StarknetDomain", nb::type_slots(StarknetDomain_slots));
}

