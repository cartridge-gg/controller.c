#include "diplomat_nanobind_common.hpp"


#include "SignMessagePolicy.hpp"


void add_SignMessagePolicy_binding(nb::handle mod) {
    PyType_Slot SignMessagePolicy_slots[] = {
        {Py_tp_free, (void *)SignMessagePolicy::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<SignMessagePolicy>(mod, "SignMessagePolicy", nb::type_slots(SignMessagePolicy_slots));
}

