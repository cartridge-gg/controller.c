#include "diplomat_nanobind_common.hpp"


#include "ContractPolicy.hpp"
#include "Method.hpp"


void add_ContractPolicy_binding(nb::handle mod) {
    PyType_Slot ContractPolicy_slots[] = {
        {Py_tp_free, (void *)ContractPolicy::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<ContractPolicy>(mod, "ContractPolicy", nb::type_slots(ContractPolicy_slots))
        .def_static("new", &ContractPolicy::new_, "name"_a= nb::none(), "description"_a= nb::none())
        .def("push_method", &ContractPolicy::push_method, "method"_a);
}

