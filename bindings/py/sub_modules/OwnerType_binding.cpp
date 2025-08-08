#include "diplomat_nanobind_common.hpp"


#include "OwnerType.hpp"


void add_OwnerType_binding(nb::handle mod) {
    nb::class_<OwnerType> e_class(mod, "OwnerType");
    
    	nb::enum_<OwnerType::Value>(e_class, "OwnerType")
    		.value("Signer", OwnerType::Signer)
    		.value("Account", OwnerType::Account)
    		.export_values();
    
    	e_class
    		.def(nb::init_implicit<OwnerType::Value>())
    		.def(nb::self == OwnerType::Value())
    		.def("__repr__", [](const OwnerType& self){
    			return nb::str(nb::cast(OwnerType::Value(self)));
    		});
}

