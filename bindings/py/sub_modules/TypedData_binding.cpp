#include "diplomat_nanobind_common.hpp"


#include "TypedData.hpp"


void add_TypedData_binding(nb::handle mod) {
    PyType_Slot TypedData_slots[] = {
        {Py_tp_free, (void *)TypedData::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<TypedData>(mod, "TypedData", nb::type_slots(TypedData_slots));
}

