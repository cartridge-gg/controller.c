#include "diplomat_nanobind_common.hpp"


#include "ErrorType.hpp"


void add_ErrorType_binding(nb::handle mod) {
    nb::class_<ErrorType> e_class(mod, "ErrorType");
    
    	nb::enum_<ErrorType::Value>(e_class, "ErrorType")
    		.value("InitError", ErrorType::InitError)
    		.value("RuntimeError", ErrorType::RuntimeError)
    		.value("SessionError", ErrorType::SessionError)
    		.value("InvalidInput", ErrorType::InvalidInput)
    		.value("NotDeployed", ErrorType::NotDeployed)
    		.value("InsufficientBalance", ErrorType::InsufficientBalance)
    		.export_values();
    
    	e_class
    		.def(nb::init_implicit<ErrorType::Value>())
    		.def(nb::self == ErrorType::Value())
    		.def("__repr__", [](const ErrorType& self){
    			return nb::str(nb::cast(ErrorType::Value(self)));
    		});
}

