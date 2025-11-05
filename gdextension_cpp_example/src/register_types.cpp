// Registration definitions for the GDExtension module
#include "register_types.h"
#include "gdexample.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

namespace godot {

void initialize_example_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<GDExample>();
}

void uninitialize_example_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

} // namespace godot

extern "C" {
// Initialization entry point. Must match .gdextension entry_symbol
GDExtensionBool GDE_EXPORT example_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
                                                GDExtensionClassLibraryPtr p_library,
                                                GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(godot::initialize_example_module);
    init_obj.register_terminator(godot::uninitialize_example_module);
    init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
