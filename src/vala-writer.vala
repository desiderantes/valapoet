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

    public class ValaWriter : GLib.Object {

        private unowned StringBuilder out_builder;
        private string indent;
        private int indent_level = 0;
        private bool trailing_newline = true;

        // State for import collection
        private string current_namespace = "";
        private GLib.List<string> usings;
        private bool is_dry_run = false;
        private GLib.List<string> importable_types = new GLib.List<string>();
        private GLib.List<string> enclosing_type_names = new GLib.List<string>();

        public ValaWriter (StringBuilder out_builder, string indent = "\t", GLib.List<string>? usings = null) {
            this.out_builder = out_builder;
            this.indent = indent;
            this.usings = new GLib.List<string>();
            if (usings != null) {
                foreach (var u in usings) {
                    if (this.usings.find_custom (u, strcmp) == null) {
                        this.usings.append (u);
                    }
                }
            }
        }

        public ValaWriter.dry_run (StringBuilder out_builder) {
            this (out_builder, "\t", new GLib.List<string>());
            this.is_dry_run = true;
        }

        public unowned GLib.List<string> get_importable_types () {
            return this.importable_types;
        }

        public void emit_file (ValaFile vala_file) {
        // Collect imports in dry run first
            var dry_sb = new StringBuilder();
            var dry_writer = new ValaWriter.dry_run (dry_sb);
            foreach (var m in vala_file.members) {
                dry_writer.emit_member (m);
            }

            var all_usings = new GLib.List<string>();
            foreach (var u in vala_file.usings) {
                if (all_usings.find_custom (u, strcmp) == null) {
                    all_usings.append (u);
                }
            }
            foreach (var imp in dry_writer.get_importable_types ()) {
                if (imp != "" && imp != "GLib") {
                    if (all_usings.find_custom (imp, strcmp) == null) {
                        all_usings.append (imp);
                    }
                }
            }

            foreach (var u in all_usings) {
                if (this.usings.find_custom (u, strcmp) == null) {
                    this.usings.append (u);
                }
            }

            if (all_usings != null && all_usings.length () > 0) {
                all_usings.sort (strcmp);
                foreach (var u in all_usings) {
                    emit ("using %s;\n", u);
                }
                emit ("\n");
            }

            uint i = 0;
            foreach (var m in vala_file.members) {
                if (i > 0) {
                    emit ("\n");
                }
                emit_member (m);
                i++;
            }
        }

        public void emit_member (Object member, string enclosing_name = "") {
            if (member is TypeSpec) {
                emit_type_spec ((TypeSpec) member);
            } else if (member is MethodSpec) {
                emit_method ((MethodSpec) member, enclosing_name);
            } else if (member is DelegateName) {
                emit_delegate ((DelegateName) member);
            } else if (member is SignalSpec) {
                emit_signal ((SignalSpec) member);
            } else if (member is FieldSpec) {
                emit_field ((FieldSpec) member);
            } else if (member is PropertySpec) {
                emit_property ((PropertySpec) member);
            }
        }

        public void emit_type_spec (TypeSpec type_spec) {
            emit_valadoc (type_spec.valadoc);
            emit_attributes (type_spec.attributes);
            emit_visibility (type_spec.visibility);
            emit_symbol_modifiers (type_spec.modifiers);

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE) {
                enclosing_type_names.append (type_spec.name);
            }

            switch (type_spec.kind) {
                case TypeSpec.Kind.CLASS :
                    emit ("class %s", type_spec.name);
                    break;
                case TypeSpec.Kind.STRUCT :
                    emit ("struct %s", type_spec.name);
                    break;
                case TypeSpec.Kind.INTERFACE:
                    emit ("interface %s", type_spec.name);
                    break;
                case TypeSpec.Kind.ENUM:
                    emit ("enum %s", type_spec.name);
                    break;
                case TypeSpec.Kind.ERROR_DOMAIN:
                    emit ("errordomain %s", type_spec.name);
                    break;
                case TypeSpec.Kind.NAMESPACE:
                    emit ("namespace %s", type_spec.name);
                    break;
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

            // Emit error domain / enum codes if present
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

            // Emit enum constants if present
            if (type_spec.enum_constants != null && type_spec.enum_constants.length () > 0) {
                bool has_members = (type_spec.methods != null && type_spec.methods.length () > 0) ||
                                   (type_spec.fields != null && type_spec.fields.length () > 0) ||
                                   (type_spec.properties != null && type_spec.properties.length () > 0) ||
                                   (type_spec.nested_types != null && type_spec.nested_types.length () > 0);
                uint enc_len = type_spec.enum_constants.length ();
                uint i = 0;
                foreach (var c in type_spec.enum_constants) {
                    if (c.valadoc != null) {
                        emit_code_block (c.valadoc);
                    }
                    emit ("%s", c.name);
                    if (c.value != null) {
                        emit (" = %d", c.value);
                    }
                    if (i < enc_len - 1) {
                        emit (",\n");
                    } else if (has_members) {
                        emit (";\n\n");
                    } else {
                        emit ("\n");
                    }
                    i++;
                }
            }

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

            // Emit construct blocks
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

            bool emitted_previous = (type_spec.fields != null && type_spec.fields.length () > 0) ||
                                    (type_spec.properties != null && type_spec.properties.length () > 0) ||
                                    (type_spec.signals != null && type_spec.signals.length () > 0) ||
                                    type_spec.static_construct_block != null ||
                                    type_spec.class_construct_block != null ||
                                    type_spec.construct_block != null;

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
            // 0: PUBLIC instance, 1: NONE instance, 2: PROTECTED instance, 3: INTERNAL instance, 4: PRIVATE instance
            // 5: PUBLIC static,   6: NONE static,   7: PROTECTED static,   8: INTERNAL static,   9: PRIVATE static
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

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE && enclosing_type_names != null && enclosing_type_names.length () > 0) {
                enclosing_type_names.remove_link (enclosing_type_names.last ());
            }

            current_namespace = previous_ns;
            decrease_indent ();
            emit ("}\n");
        }

        public void emit_property (PropertySpec prop_spec) {
            emit_attributes (prop_spec.attributes);
            emit_visibility (prop_spec.visibility);
            emit_symbol_modifiers (prop_spec.modifiers);
            var unowned_type = prop_spec.type_name.copy ();
            unowned_type.is_owned = false;
            emit ("%s %s", lookup_name (unowned_type), prop_spec.name);
            emit (" {\n");
            increase_indent ();

            bool has_bodies = (prop_spec.get_body != null || prop_spec.set_body != null || prop_spec.construct_body != null);

            if (!has_bodies) {
            // Auto property with optional getter/setter modifiers
                if (prop_spec.type_name.is_owned) {
                    emit ("owned ");
                }
                emit_visibility (prop_spec.get_visibility);
                emit_symbol_modifiers (prop_spec.get_modifiers);
                emit ("get;");
                if (prop_spec.is_construct_only) {
                    emit (" construct;");
                } else if (!prop_spec.is_read_only) {
                    emit (" ");
                    emit_visibility (prop_spec.set_visibility);
                    emit_symbol_modifiers (prop_spec.set_modifiers);
                    emit ("set;");
                }
                emit ("\n");
            } else {
                if (prop_spec.get_body != null) {
                    if (prop_spec.type_name.is_owned) {
                        emit ("owned ");
                    }
                    emit_visibility (prop_spec.get_visibility);
                    emit_symbol_modifiers (prop_spec.get_modifiers);
                    emit ("get {\n");
                    increase_indent ();
                    emit_code_block (prop_spec.get_body);
                    decrease_indent ();
                    emit ("}\n");
                }

                if (prop_spec.set_body != null) {
                    emit_visibility (prop_spec.set_visibility);
                    emit_symbol_modifiers (prop_spec.set_modifiers);
                    emit ("set {\n");
                    increase_indent ();
                    emit_code_block (prop_spec.set_body);
                    decrease_indent ();
                    emit ("}\n");
                }

                if (prop_spec.construct_body != null) {
                    emit ("construct {\n");
                    increase_indent ();
                    emit_code_block (prop_spec.construct_body);
                    decrease_indent ();
                    emit ("}\n");
                }
            }

            if (prop_spec.is_construct_set) {
                emit ("construct set;\n");
            }

            if (prop_spec.default_value != null) {
                emit ("default = ");
                emit_code_block (prop_spec.default_value);
                emit (";\n");
            }

            decrease_indent ();
            emit ("}\n");
        }

        public void emit_method (MethodSpec method_spec, string enclosing_name = "") {
            emit_valadoc (method_spec.valadoc);
            emit_attributes (method_spec.attributes);
            emit_visibility (method_spec.visibility);
            emit_symbol_modifiers (method_spec.modifiers);

            if (method_spec.kind == MethodSpec.Kind.METHOD) {
                if (method_spec.return_type != null) {
                    emit ("%s ", lookup_name (method_spec.return_type));
                } else {
                    emit ("void ");
                }
                emit ("%s", method_spec.name);
            } else if (method_spec.kind == MethodSpec.Kind.CONSTRUCTOR) {
                string ctor_name = (enclosing_name != "") ? enclosing_name : method_spec.name;
                emit ("%s", ctor_name);
            } else if (method_spec.kind == MethodSpec.Kind.NAMED_CONSTRUCTOR) {
                string ctor_name = (enclosing_name != "") ? enclosing_name : "Self";
                emit ("%s.%s", ctor_name, method_spec.name);
            } else if (method_spec.kind == MethodSpec.Kind.DESTRUCTOR) {
                string ctor_name = (enclosing_name != "") ? enclosing_name : "Self";
                emit ("~%s", ctor_name);
            }

            if (method_spec.type_variables != null && method_spec.type_variables.length () > 0) {
                emit ("<");
                uint i = 0;
                foreach (var tv in method_spec.type_variables) {
                    if (i > 0) emit (", ");
                    emit (tv.to_string ());
                    i++;
                }
                emit (">");
            }

            emit (" (");

            if (method_spec.parameters != null && method_spec.parameters.length () > 0) {
                uint i = 0;
                foreach (var param in method_spec.parameters) {
                    if (i > 0) emit (", ");
                    emit_attributes (param.attributes, true);
                    emit_symbol_modifiers (param.modifiers);
                    if (param.direction == ParameterDirection.OUT) {
                        emit ("out ");
                    } else if (param.direction == ParameterDirection.REF) {
                        emit ("ref ");
                    }
                    if (param.is_params) {
                        emit ("params ");
                    }
                    emit ("%s %s", lookup_name (param.type_name), param.name);
                    if (param.default_value != null) {
                        emit (" = ");
                        emit_code_block (param.default_value);
                    }
                    i++;
                }
            }
            if (method_spec.variadic) {
                if (method_spec.parameters != null && method_spec.parameters.length () > 0) {
                    emit (", ");
                }
                emit ("...");
            }
            emit (")");

            if (method_spec.throws_errors != null && method_spec.throws_errors.length () > 0) {
                emit (" throws ");
                string[] errs = {};
                foreach (var err in method_spec.throws_errors) {
                    errs += lookup_name (err);
                }
                emit ("%s", string.joinv (", ", errs));
            }

            // Contract programming (requires / ensures)
            if (method_spec.requires_contracts != null && method_spec.requires_contracts.length () > 0) {
                foreach (var req in method_spec.requires_contracts) {
                    emit ("\n");
                    emit ("requires (");
                    emit_code_block (req);
                    emit (")");
                }
            }
            if (method_spec.ensures_contracts != null && method_spec.ensures_contracts.length () > 0) {
                foreach (var ens in method_spec.ensures_contracts) {
                    emit ("\n");
                    emit ("ensures (");
                    emit_code_block (ens);
                    emit (")");
                }
            }

            if (method_spec.modifiers != null && method_spec.modifiers.find (SymbolModifier.ABSTRACT) != null) {
                emit (";\n");
            } else {
                emit (" {\n");
                increase_indent ();
                emit_code_block (method_spec.code);
                decrease_indent ();
                emit ("}\n");
            }
        }

        public void emit_signal (SignalSpec signal_spec) {
            emit_attributes (signal_spec.attributes);
            emit_visibility (signal_spec.visibility);
            emit_symbol_modifiers (signal_spec.modifiers);
            emit ("signal ");
            if (signal_spec.return_type != null) {
                emit ("%s ", lookup_name (signal_spec.return_type));
            } else {
                emit ("void ");
            }
            emit ("%s (", signal_spec.name);
            if (signal_spec.parameters != null && signal_spec.parameters.length () > 0) {
                uint i = 0;
                foreach (var p in signal_spec.parameters) {
                    if (i > 0) emit (", ");
                    emit_attributes (p.attributes, true);
                    emit ("%s %s", lookup_name (p.type_name), p.name);
                    i++;
                }
            }
            emit (");\n");
        }

        public void emit_field (FieldSpec field_spec) {
            emit_attributes (field_spec.attributes);
            emit_visibility (field_spec.visibility);
            emit_symbol_modifiers (field_spec.modifiers);
            emit ("%s %s", lookup_name (field_spec.type_name), field_spec.name);
            if (field_spec.initializer != null) {
                emit (" = ");
                emit_code_block (field_spec.initializer);
            }
            emit (";\n");
        }

        public void emit_valadoc (CodeBlock? valadoc) {
            if (valadoc == null || valadoc.is_empty ())return;
            emit ("/**\n");
            var sb = new StringBuilder ();
            var temp_writer = new ValaWriter (sb, indent, usings);
            temp_writer.emit_code_block (valadoc);
            var doc_lines = sb.str.split ("\n");
            foreach (var line in doc_lines) {
                if (line != "") {
                    emit (" * %s\n", line);
                }
            }
            emit (" */\n");
        }

        public void emit_attributes (GLib.List<AttributeSpec> attributes, bool inline_attr = false) {
            if (attributes == null || attributes.length () == 0) return;

            if (inline_attr) {
                emit ("[");
                uint i = 0;
                foreach (var attr in attributes) {
                    if (i > 0) emit (", ");
                    emit_single_attribute_content (attr);
                    i++;
                }
                emit ("] ");
            } else {
                foreach (var attr in attributes) {
                    emit ("[");
                    emit_single_attribute_content (attr);
                    emit ("]\n");
                }
            }
        }

        private void emit_single_attribute_content (AttributeSpec attr) {
            emit (attr.name);
            if (attr.arguments != null && attr.arguments.size () > 0) {
                emit (" (");
                GLib.List<string> keys = new GLib.List<string>();
                attr.arguments.foreach ((k, v) => {
                    keys.append (k);
                });
                keys.sort (strcmp);
                int idx = 0;
                foreach (var k in keys) {
                    if (idx > 0) emit (", ");
                    emit ("%s = ", k);
                    emit_code_block (attr.arguments.lookup (k));
                    idx++;
                }
                emit (")");
            }
        }

        public void emit_delegate (DelegateName delegate_spec) {
            emit_attributes (delegate_spec.attributes);
            emit_visibility (delegate_spec.visibility);
            emit_symbol_modifiers (delegate_spec.modifiers);
            emit ("delegate %s %s (", lookup_name (delegate_spec.return_type), delegate_spec.name);
            if (delegate_spec.parameters != null && delegate_spec.parameters.length () > 0) {
                uint i = 0;
                foreach (var param in delegate_spec.parameters) {
                    if (i > 0) emit (", ");
                    emit_attributes (param.attributes, true);
                    emit ("%s %s", lookup_name (param.type_name), param.name);
                    i++;
                }
            }
            emit (");\n");
        }

        public void emit_code_block (CodeBlock code_block) {
            int arg_index = 0;
            foreach (var part in code_block.format_parts) {
                if (part == "$>") {
                    increase_indent ();
                } else if (part == "$<") {
                    decrease_indent ();
                } else if (part == "$[") {
                // line statement start
                } else if (part == "$]") {
                // line statement end
                } else if (part == "$W") {
                    emit (" "); // wrapping space
                } else if (part == "$Z") {
                // zero-width space
                } else if (part == "$L" || part == "$S" || part == "$T" || part == "$N") {
                    if (code_block.args != null && arg_index < code_block.args.length ()) {
                        unowned GLib.List<Value ?> node = code_block.args.nth (arg_index++);
                        var val = (node != null) ? node.data : null;
                        if (val != null) {
                            if (val.holds (typeof (string))) {
                                string str = val.get_string ();
                                if (part == "$S") {
                                    emit ("\"%s\"", str.compress ());
                                } else {
                                    emit ("%s", str);
                                }
                            } else if (val.holds (typeof (Object))) {
                                Object? obj = val.get_object ();
                                if (obj != null) {
                                    if (part == "$T" && obj is TypeName) {
                                        emit (lookup_name ((TypeName) obj));
                                    } else if (part == "$N") {
                                        if (obj is MethodSpec)emit (((MethodSpec) obj).name);
                                            else if (obj is FieldSpec)emit (((FieldSpec) obj).name);
                                            else if (obj is PropertySpec)emit (((PropertySpec) obj).name);
                                            else if (obj is ParameterSpec)emit (((ParameterSpec) obj).name);
                                            else if (obj is TypeSpec)emit (((TypeSpec) obj).name);
                                            else if (obj is SignalSpec)emit (((SignalSpec) obj).name);
                                        else emit (obj.get_type ().name ());
                                    } else if (obj is CodeBlock) {
                                        emit_code_block ((CodeBlock) obj);
                                    } else if (obj is TypeName) {
                                        emit (lookup_name ((TypeName) obj));
                                    } else {
                                        emit (obj.get_type ().name ());
                                    }
                                }
                            }
                        }
                    }
                } else {
                    emit (part);
                }
            }
        }

        private string lookup_name (TypeName type) {
            string res = type.to_string ();
            if (type is ClassName) {
                var cn = (ClassName) type;
                if (cn.namespace_name != "") {
                    if (importable_types.find_custom (cn.namespace_name, strcmp) == null) {
                        importable_types.append (cn.namespace_name);
                    }
                }
                res = cn.simple_name;
                bool collides = cn.simple_name != "" && enclosing_type_names.find_custom (cn.simple_name, strcmp) != null;
                if (collides || (cn.namespace_name != "" && usings.find_custom (cn.namespace_name, strcmp) == null && current_namespace != cn.namespace_name)) {
                    res = cn.canonical_name;
                }
            } else if (type is ParameterizedTypeName) {
                var ptn = (ParameterizedTypeName) type;
                string[] args_str = {};
                foreach (var arg in ptn.type_arguments) {
                    args_str += lookup_name (arg);
                }
                res = lookup_name (ptn.raw_type) + "<" + string.joinv (", ", args_str) + ">";
            } else if (type is ArrayTypeName) {
                var atn = (ArrayTypeName) type;
                var commas = new string[atn.rank];
                for (int i = 0; i < atn.rank; i++) {
                    commas[i] = "";
                }
                string rank_str = string.joinv (",", commas);
                res = lookup_name (atn.component_type) + "[" + rank_str + "]";
            } else if (type is PointerTypeName) {
                var ptn = (PointerTypeName) type;
                return lookup_name (ptn.pointed_to_type) + "*";
            } else if (type is TypeVariableName) {
                var tvn = (TypeVariableName) type;
                res = tvn.name;
            }

            if (type.is_unowned)res = "unowned " + res;
            if (type.is_owned)res = "owned " + res;
            if (type.is_weak)res = "weak " + res;
            if (type.is_nullable)res += "?";
            return res;
        }

        public void emit_visibility (Visibility vis) {
            if (vis != Visibility.NONE) {
                emit ("%s ", vis.to_string ());
            }
        }

        public void emit_symbol_modifiers (GLib.List<SymbolModifier> modifiers) {
            if (modifiers == null) return;
            foreach (var m in modifiers) {
                emit ("%s ", m.to_string ());
            }
        }

        [PrintfFormat ()]
        public void emit (string format, ...) {
            var va = va_list ();
            emit_valist (format, va);
        }

        public void emit_valist (string format, va_list va) {
            string formatted = format.vprintf (va);
            var lines = formatted.split ("\n");
            for (int i = 0; i < lines.length; i++) {
                if (i > 0) {
                    out_builder.append_c ('\n');
                    trailing_newline = true;
                }
                if (lines[i] != "") {
                    if (trailing_newline) {
                        emit_indent ();
                        trailing_newline = false;
                    }
                    out_builder.append (lines[i]);
                }
            }
        }

        public void increase_indent () {
            this.indent_level++;
        }

        public void decrease_indent () {
            this.indent_level--;
        }

        private void emit_indent () {
            for (int i = 0; i < indent_level; i++) {
                out_builder.append (indent);
            }
        }

    }

}
