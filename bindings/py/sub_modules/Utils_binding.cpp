#include "diplomat_nanobind_common.hpp"


#include "Utils.hpp"


void add_Utils_binding(nb::handle mod) {
    PyType_Slot Utils_slots[] = {
        {Py_tp_free, (void *)Utils::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<Utils>(mod, "Utils", nb::type_slots(Utils_slots))
    	.def_static("signer_to_guid", &Utils::signer_to_guid, "signer"_a)
    	.def_static("subscribe_create_session", &Utils::subscribe_create_session, "session_key_guid"_a, "cartridge_api_url"_a);
}

