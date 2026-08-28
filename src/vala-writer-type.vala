/*
 * Copyright 2026 ValaPoet Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

namespace ValaPoet {

    public partial class ValaWriter {

        public void emit_type_spec (TypeSpec type_spec) {
            emit_comment (type_spec.comment);
            emit_valadoc (type_spec.valadoc);
            emit_attributes (type_spec.attributes);
            emit_visibility (type_spec.visibility);
            emit_symbol_modifiers (type_spec.modifiers);

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE) {
                enclosing_type_names.append (type_spec.name);
            }

            emit_type_header (type_spec);

            emit (" {\n");
            if (type_spec.kind == TypeSpec.Kind.NAMESPACE) {
                emit ("\n");
            }
            increase_indent ();

            string previous_ns = current_namespace;
            if (type_spec.kind == TypeSpec.Kind.NAMESPACE) {
                if (current_namespace != "") {
                    current_namespace += "." + type_spec.name;
                } else {
                    current_namespace = type_spec.name;
                }
            }

            emit_error_domain_codes (type_spec);
            emit_enum_constants (type_spec);

            // Emit members inside type
            foreach (var f in type_spec.fields) {
                emit_field (f);
            }
            foreach (var p in type_spec.properties) {
                emit_property (p);
            }
            foreach (var sig in type_spec.signals) {
                emit_signal (sig);
            }

            emit_construct_blocks (type_spec);

            bool emitted_previous = (type_spec.enum_constants != null && type_spec.enum_constants.length () > 0) ||
                                    (type_spec.fields != null && type_spec.fields.length () > 0) ||
                                    (type_spec.properties != null && type_spec.properties.length () > 0) ||
                                    (type_spec.signals != null && type_spec.signals.length () > 0) ||
                                    type_spec.static_construct_block != null ||
                                    type_spec.class_construct_block != null ||
                                    type_spec.construct_block != null;

            emit_methods_and_nested (type_spec, ref emitted_previous);

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE && enclosing_type_names != null && enclosing_type_names.length () > 0) {
                enclosing_type_names.remove_link (enclosing_type_names.last ());
            }

            current_namespace = previous_ns;
            decrease_indent ();
            emit ("}\n");
        }

        private void emit_type_header (TypeSpec type_spec) {
            switch (type_spec.kind) {
                case TypeSpec.Kind.CLASS: emit ("class %s", type_spec.name); break;
                case TypeSpec.Kind.STRUCT: emit ("struct %s", type_spec.name); break;
                case TypeSpec.Kind.INTERFACE: emit ("interface %s", type_spec.name); break;
                case TypeSpec.Kind.ENUM: emit ("enum %s", type_spec.name); break;
                case TypeSpec.Kind.ERROR_DOMAIN: emit ("errordomain %s", type_spec.name); break;
                case TypeSpec.Kind.NAMESPACE: emit ("namespace %s", type_spec.name); break;
            }

            if (type_spec.type_variables != null && type_spec.type_variables.length () > 0) {
                emit ("<");
                uint i = 0;
                foreach (var tv in type_spec.type_variables) {
                    if (i > 0) emit (", ");
                    emit (tv.to_string ());
                    i++;
                }
                emit (">");
            }

            if (type_spec.superclass != null || (type_spec.superinterfaces != null && type_spec.superinterfaces.length () > 0)) {
                emit (" : ");
                string[] super_types = {};
                if (type_spec.superclass != null) {
                    super_types += lookup_name (type_spec.superclass);
                }
                foreach (var iface in type_spec.superinterfaces) {
                    super_types += lookup_name (iface);
                }
                emit ("%s", string.joinv (", ", super_types));
            }
        }

        private void emit_error_domain_codes (TypeSpec type_spec) {
            if (type_spec.error_codes != null && type_spec.error_codes.length () > 0) {
                uint ec_len = type_spec.error_codes.length ();
                uint i = 0;
                foreach (var ec in type_spec.error_codes) {
                    if (i > 0) emit (",\n");
                    emit ("%s", ec);
                    if (i == ec_len - 1) {
                        emit ("\n");
                    }
                    i++;
                }
            }
        }

        private void emit_enum_constants (TypeSpec type_spec) {
            if (type_spec.enum_constants != null && type_spec.enum_constants.length () > 0) {
                bool has_members = (type_spec.methods != null && type_spec.methods.length () > 0) ||
                                   (type_spec.fields != null && type_spec.fields.length () > 0) ||
                                   (type_spec.properties != null && type_spec.properties.length () > 0) ||
                                   (type_spec.nested_types != null && type_spec.nested_types.length () > 0);
                uint enc_len = type_spec.enum_constants.length ();
                uint i = 0;
                foreach (var c in type_spec.enum_constants) {
                    if (c.comment != null) {
                        emit_comment (c.comment);
                    }
                    if (c.valadoc != null) {
                        emit_valadoc (c.valadoc);
                    }
                    emit ("%s", c.name);
                    if (c.value != null) {
                        emit (" = %d", c.value);
                    }
                    if (i < enc_len - 1) {
                        emit (",\n");
                    } else if (has_members) {
                        emit (";\n");
                    } else {
                        emit ("\n");
                    }
                    i++;
                }
            }
        }

        private void emit_construct_blocks (TypeSpec type_spec) {
            if (type_spec.static_construct_block != null) {
                emit ("static construct {\n");
                increase_indent ();
                emit_code_block (type_spec.static_construct_block);
                decrease_indent ();
                emit ("}\n");
            }
            if (type_spec.class_construct_block != null) {
                emit ("class construct {\n");
                increase_indent ();
                emit_code_block (type_spec.class_construct_block);
                decrease_indent ();
                emit ("}\n");
            }
            if (type_spec.construct_block != null) {
                emit ("construct {\n");
                increase_indent ();
                emit_code_block (type_spec.construct_block);
                decrease_indent ();
                emit ("}\n");
            }
        }

        private void emit_methods_and_nested (TypeSpec type_spec, ref bool emitted_previous) {
            // Separate constructors/destructors from regular methods
            var ctors = new GLib.List<MethodSpec>();
            var regular_methods = new GLib.List<MethodSpec>();
            foreach (var m in type_spec.methods) {
                if (m.kind != MethodSpec.Kind.METHOD) {
                    ctors.append (m);
                } else {
                    regular_methods.append (m);
                }
            }

            // Emit constructors & destructors
            uint ctor_i = 0;
            foreach (var ctor in ctors) {
                if (ctor_i > 0 || emitted_previous) {
                    emit ("\n");
                }
                emit_method (ctor, type_spec.name);
                emitted_previous = true;
                ctor_i++;
            }

            // Group regular methods by visibility and staticness
            GLib.List<MethodSpec>[] buckets = new GLib.List<MethodSpec>[10];
            for (int k = 0; k < 10; k++) {
                buckets[k] = new GLib.List<MethodSpec>();
            }

            foreach (var m in regular_methods) {
                bool is_static = m.modifiers.find (SymbolModifier.STATIC) != null;
                int base_idx = is_static ? 5 : 0;
                int vis_offset = 0;
                switch (m.visibility) {
                    case Visibility.PUBLIC: vis_offset = 0; break;
                    case Visibility.NONE: vis_offset = 1; break;
                    case Visibility.PROTECTED: vis_offset = 2; break;
                    case Visibility.INTERNAL: vis_offset = 3; break;
                    case Visibility.PRIVATE: vis_offset = 4; break;
                }
                buckets[base_idx + vis_offset].append (m);
            }

            foreach (unowned var bucket in buckets) {
                foreach (var m in bucket) {
                    if (emitted_previous) {
                        emit ("\n");
                    }
                    emit_method (m, type_spec.name);
                    emitted_previous = true;
                }
            }

            // Emit nested types with proper newline spacing
            foreach (var nt in type_spec.nested_types) {
                if (emitted_previous) {
                    emit ("\n");
                }
                emit_type_spec (nt);
                emitted_previous = true;
            }
        }

    }

}
