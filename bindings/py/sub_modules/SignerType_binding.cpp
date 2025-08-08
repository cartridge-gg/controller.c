#include "diplomat_nanobind_common.hpp"


#include "SignerType.hpp"


void add_SignerType_binding(nb::handle mod) {
    nb::class_<SignerType> e_class(mod, "SignerType");
    
    	nb::enum_<SignerType::Value>(e_class, "SignerType")
    		.value("Starknet", SignerType::Starknet)
    		.value("StarknetAccount", SignerType::StarknetAccount)
    		.value("Eip191", SignerType::Eip191)
    		.value("Webauthn", SignerType::Webauthn)
    		.value("Siws", SignerType::Siws)
    		.value("Secp256k1", SignerType::Secp256k1)
    		.value("Secp256r1", SignerType::Secp256r1)
    		.export_values();
    
    	e_class
    		.def(nb::init_implicit<SignerType::Value>())
    		.def(nb::self == SignerType::Value())
    		.def("__repr__", [](const SignerType& self){
    			return nb::str(nb::cast(SignerType::Value(self)));
    		});
}

