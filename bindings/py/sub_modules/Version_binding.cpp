#include "diplomat_nanobind_common.hpp"


#include "Version.hpp"


void add_Version_binding(nb::handle mod) {
    nb::class_<Version> e_class(mod, "Version");
    
    	nb::enum_<Version::Value>(e_class, "Version")
    		.value("V1_0_4", Version::V1_0_4)
    		.value("V1_0_5", Version::V1_0_5)
    		.value("V1_0_6", Version::V1_0_6)
    		.value("V1_0_7", Version::V1_0_7)
    		.value("V1_0_8", Version::V1_0_8)
    		.value("V1_0_9", Version::V1_0_9)
    		.value("LATEST", Version::LATEST)
    		.export_values();
    
    	e_class
    		.def(nb::init_implicit<Version::Value>())
    		.def(nb::self == Version::Value())
    		.def("__repr__", [](const Version& self){
    			return nb::str(nb::cast(Version::Value(self)));
    		});
}

