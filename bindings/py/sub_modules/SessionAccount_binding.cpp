#include "diplomat_nanobind_common.hpp"


#include "DiplomatCallList.hpp"
#include "DiplomatFelt.hpp"
#include "DiplomatSessionPolicies.hpp"
#include "DiplomatSigner.hpp"
#include "SessionAccount.hpp"


void add_SessionAccount_binding(nb::handle mod) {
    PyType_Slot SessionAccount_slots[] = {
        {Py_tp_free, (void *)SessionAccount::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<SessionAccount>(mod, "SessionAccount", nb::type_slots(SessionAccount_slots))
        .def_static("create_from_subscribe_create_session", &SessionAccount::create_from_subscribe_create_session, "signer"_a, "policies"_a, "rpc_url"_a, "cartridge_api_url"_a)
        .def("execute", &SessionAccount::execute, "calls"_a)
        .def("execute_from_outside_v3", &SessionAccount::execute_from_outside_v3, "calls"_a)
        .def_static("new_as_registered", &SessionAccount::new_as_registered, "rpc_url"_a, "signer"_a, "address"_a, "owner_guid"_a, "chain_id"_a, "policies"_a, "session_expiration"_a);
}

