// Registration declarations for the GDExtension module
#ifndef GD_EXAMPLE_REGISTER_TYPES_H
#define GD_EXAMPLE_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

namespace godot {

void initialize_example_module(ModuleInitializationLevel p_level);
void uninitialize_example_module(ModuleInitializationLevel p_level);

} // namespace godot

#endif // GD_EXAMPLE_REGISTER_TYPES_H
