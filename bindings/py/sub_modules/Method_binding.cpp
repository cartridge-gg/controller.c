#include "diplomat_nanobind_common.hpp"


#include "Method.hpp"


void add_Method_binding(nb::handle mod) {
    PyType_Slot Method_slots[] = {
        {Py_tp_free, (void *)Method::operator delete },
        {Py_tp_dealloc, (void *)diplomat_tp_dealloc},
        {0, nullptr}};
    
    nb::class_<Method>(mod, "Method", nb::type_slots(Method_slots))
        .def_static("new", &Method::new_, "name"_a, "description"_a, "entrypoint"_a, "is_enabled"_a, "is_required"_a, "is_paymastered"_a);
}

