#include "diplomat_nanobind_common.hpp"
#include <../src/nb_internals.h>  // Required for shimming

// Forward declarations for binding add functions

void add_CONTROLLERS_binding(nb::handle);
void add_DiplomatCall_binding(nb::handle);
void add_DiplomatCallList_binding(nb::handle);
void add_DiplomatFelt_binding(nb::handle);
void add_Controller_binding(nb::handle);
void add_ControllerError_binding(nb::handle);
void add_DiplomatOwner_binding(nb::handle);
void add_DiplomatSigner_binding(nb::handle);
void add_Eip191Signer_binding(nb::handle);
void add_StarknetSigner_binding(nb::handle);
void add_WebauthnSigner_binding(nb::handle);
void add_SignerType_binding(nb::handle);
void add_Version_binding(nb::handle);
void add_ErrorType_binding(nb::handle);
void add_OwnerType_binding(nb::handle);

// Nanobind does not usually support custom deleters, so we're shimming some of the machinery to add that ability.
// On module init, the dummy type will have the normal nanobind inst_dealloc function in the tp_dealloc slot, so we
// pull it out, store it here, and then call it in the tp_dealloc function we are shimming in to all our types.
// Our custom tp_dealloc function will call the tp_free function instead of `delete`, allowing us effectively to override
// the delete operator.
// See https://nanobind.readthedocs.io/en/latest/lowlevel.html#customizing-type-creation and
// https://github.com/wjakob/nanobind/discussions/932
void (*nb_tp_dealloc)(void *) = nullptr;

void diplomat_tp_dealloc(PyObject *self)
{
    using namespace nb::detail;
    PyTypeObject *tp = Py_TYPE(self);
    const type_data *t = nb_type_data(tp);

    nb_inst *inst = (nb_inst *)self;
    void *p = inst_ptr(inst);
    if (inst->destruct)
    {
        inst->destruct = false;
        check(t->flags & (uint32_t)type_flags::is_destructible,
              "nanobind::detail::inst_dealloc(\"%s\"): attempted to call "
              "the destructor of a non-destructible type!",
              t->name);
        if (t->flags & (uint32_t)type_flags::has_destruct)
            t->destruct(p);
    }
    if (inst->cpp_delete)
    {
        inst->cpp_delete = false;
        auto tp_free = (freefunc)(PyType_GetSlot(tp, Py_tp_free));
        (*tp_free)(p);
    }
    (*nb_tp_dealloc)(self);
}

struct _Dummy {};

NB_MODULE(controller_c, controller_c_mod)
{
	{
		nb::class_<_Dummy> dummy(controller_c_mod, "__dummy__");
		nb_tp_dealloc = (void (*)(void *))nb::type_get_slot(dummy, Py_tp_dealloc);
	}

    nb::class_<std::monostate>(controller_c_mod, "monostate")
		.def("__repr__", [](const std::monostate &)
			 { return ""; })
		.def("__str__", [](const std::monostate &)
			 { return ""; });
             

    // Module declarations
    // Add bindings
    add_CONTROLLERS_binding(controller_c_mod);
    add_DiplomatCall_binding(controller_c_mod);
    add_DiplomatCallList_binding(controller_c_mod);
    add_DiplomatFelt_binding(controller_c_mod);
    add_Controller_binding(controller_c_mod);
    add_ControllerError_binding(controller_c_mod);
    add_DiplomatOwner_binding(controller_c_mod);
    add_DiplomatSigner_binding(controller_c_mod);
    add_Eip191Signer_binding(controller_c_mod);
    add_StarknetSigner_binding(controller_c_mod);
    add_WebauthnSigner_binding(controller_c_mod);
    add_SignerType_binding(controller_c_mod);
    add_Version_binding(controller_c_mod);
    add_ErrorType_binding(controller_c_mod);
    add_OwnerType_binding(controller_c_mod);
    
	
}