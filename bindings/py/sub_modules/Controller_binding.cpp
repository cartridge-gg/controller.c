#include "diplomat_nanobind_common.hpp"


#include "Controller.hpp"


void add_Controller_binding(nb::handle mod) {
    PyType_Slot Controller_slots[] = {
        {Py_tp_free, (void *)Controller::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<Controller>(mod, "Controller", nb::type_slots(Controller_slots))
    	.def("address", &Controller::address)
    	.def("app_id", &Controller::app_id)
    	.def("chain_id", &Controller::chain_id)
    	.def("delegate_account", &Controller::delegate_account)
    	.def("disconnect", &Controller::disconnect)
    	.def("execute", &Controller::execute, "calls"_a)
    	.def_static("from_storage", &Controller::from_storage, "app_id"_a)
    	.def_static("new", &Controller::new_, "app_id"_a, "username"_a, "class_hash"_a, "rpc_url"_a, "owner"_a, "address"_a, "chain_id"_a)
    	.def_static("new_headless", &Controller::new_headless, "app_id"_a, "username"_a, "class_hash"_a, "rpc_url"_a, "owner"_a, "chain_id"_a)
    	.def("signup", &Controller::signup, "signer_type"_a, "session_expiration"_a= nb::none(), "cartridge_api_url"_a= nb::none())
    	.def("transfer", &Controller::transfer, "recipient"_a, "amount"_a)
    	.def("username", &Controller::username);
}

