#include "diplomat_nanobind_common.hpp"


#include "StarknetType.hpp"


void add_StarknetType_binding(nb::handle mod) {
    PyType_Slot StarknetType_slots[] = {
        {Py_tp_free, (void *)StarknetType::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<StarknetType>(mod, "StarknetType", nb::type_slots(StarknetType_slots));
}

