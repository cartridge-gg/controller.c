#include "diplomat_nanobind_common.hpp"


#include "ContractPolicy.hpp"
#include "DiplomatSessionPolicies.hpp"
#include "SignMessagePolicy.hpp"


void add_DiplomatSessionPolicies_binding(nb::handle mod) {
    PyType_Slot DiplomatSessionPolicies_slots[] = {
        {Py_tp_free, (void *)DiplomatSessionPolicies::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<DiplomatSessionPolicies>(mod, "DiplomatSessionPolicies", nb::type_slots(DiplomatSessionPolicies_slots))
        .def("add_contract_policy", &DiplomatSessionPolicies::add_contract_policy, "address"_a, "policy"_a)
        .def("add_message_policy", &DiplomatSessionPolicies::add_message_policy, "policy"_a)
        .def_static("new", &DiplomatSessionPolicies::new_)
        .def("to_url_string", &DiplomatSessionPolicies::to_url_string);
}

