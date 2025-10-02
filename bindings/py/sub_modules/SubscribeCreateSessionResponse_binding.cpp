#include "diplomat_nanobind_common.hpp"


#include "SubscribeCreateSessionResponse.hpp"


void add_SubscribeCreateSessionResponse_binding(nb::handle mod) {
    PyType_Slot SubscribeCreateSessionResponse_slots[] = {
        {Py_tp_free, (void *)SubscribeCreateSessionResponse::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<SubscribeCreateSessionResponse>(mod, "SubscribeCreateSessionResponse", nb::type_slots(SubscribeCreateSessionResponse_slots));
}

