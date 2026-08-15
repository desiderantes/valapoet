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

using Gee;

namespace ValaPoet {

    public class ValaWriter : GLib.Object {

        private StringBuilder? _owned_sb = null;
        private unowned StringBuilder out_builder;
        private string _indent;
        private int indent_level = 0;
        private bool trailing_newline = true;

        // State for import collection
        private string current_namespace = "";
        private Gee.HashSet<string> usings;
        private bool is_dry_run = false;
        private Gee.HashSet<string> importable_types = new Gee.HashSet<string>();
        private Gee.ArrayList<string> enclosing_type_names = new Gee.ArrayList<string>();

        public ValaWriter (StringBuilder out_builder, string indent = "\t", Gee.HashSet<string>? usings = null) {
            this.out_builder = out_builder;
            this._indent = indent;
            this.usings = (usings != null) ? usings : new Gee.HashSet<string>();
        }

        public ValaWriter.dry_run () {
            var sb = new StringBuilder ();
            this._owned_sb = (owned) sb;
            this.out_builder = this._owned_sb;
            this._indent = "\t";
            this.usings = new Gee.HashSet<string>();
            this.is_dry_run = true;
        }

        public Gee.HashSet<string> get_importable_types () {
            return this.importable_types;
        }

        public void emit_file (ValaFile vala_file) {
        // Collect imports in dry run first
            var dry_writer = new ValaWriter.dry_run ();
            foreach (var m in vala_file.members) {
                dry_writer.emit_member (m);
            }

            var all_usings = new Gee.HashSet<string>();
            all_usings.add_all (vala_file.usings);
            foreach (var imp in dry_writer.get_importable_types ()) {
                if (imp != "" && imp != "GLib") {
                    all_usings.add (imp);
                }
            }

            this.usings.add_all (all_usings);

            if (!all_usings.is_empty) {
                var sorted_usings = new Gee.ArrayList<string>();
                sorted_usings.add_all (all_usings);
                sorted_usings.sort ();
                foreach (var u in sorted_usings) {
                    emit ("using %s;\n", u);
                }
                emit ("\n");
            }

            for (int i = 0; i < vala_file.members.size; i++) {
                if (i > 0) {
                    emit ("\n");
                }
                emit_member (vala_file.members.get (i));
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
            emit_modifiers (type_spec.modifiers);

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE) {
                enclosing_type_names.add (type_spec.name);
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

            if (!type_spec.type_variables.is_empty) {
                emit ("<");
                for (int i = 0; i < type_spec.type_variables.size; i++) {
                    if (i > 0)emit (", ");
                    emit (type_spec.type_variables.get (i).to_string ());
                }
                emit (">");
            }

            if (type_spec.superclass != null || !type_spec.superinterfaces.is_empty) {
                emit (" : ");
                var super_types = new Gee.ArrayList<string>();
                if (type_spec.superclass != null) {
                    super_types.add (lookup_name (type_spec.superclass));
                }
                foreach (var iface in type_spec.superinterfaces) {
                    super_types.add (lookup_name (iface));
                }
                emit ("%s", string.joinv (", ", (string[]) super_types.to_array ()));
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
            for (int i = 0; i < type_spec.error_codes.size; i++) {
                if (i > 0)emit (",\n");
                emit ("%s", type_spec.error_codes.get (i));
                if (i == type_spec.error_codes.size - 1) {
                    emit ("\n");
                }
            }

            // Emit enum constants if present
            if (!type_spec.enum_constants.is_empty) {
                bool has_members = !type_spec.methods.is_empty || !type_spec.fields.is_empty || !type_spec.properties.is_empty || !type_spec.nested_types.is_empty;
                for (int i = 0; i < type_spec.enum_constants.size; i++) {
                    var c = type_spec.enum_constants.get (i);
                    if (c.valadoc != null) {
                        emit_code_block (c.valadoc);
                    }
                    emit ("%s", c.name);
                    if (c.value != null) {
                        emit (" = %d", c.value);
                    }
                    if (i < type_spec.enum_constants.size - 1) {
                        emit (",\n");
                    } else if (has_members) {
                        emit (";\n\n");
                    } else {
                        emit ("\n");
                    }
                }
            }

            // Emit construct blocks if present
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

            // Emit members inside type
            foreach (var sig in type_spec.signals) {
                emit_signal (sig);
            }
            foreach (var f in type_spec.fields) {
                emit_field (f);
            }
            foreach (var p in type_spec.properties) {
                emit_property (p);
            }
            for (int i = 0; i < type_spec.methods.size; i++) {
                if (i > 0) {
                    emit ("\n");
                }
                emit_method (type_spec.methods.get (i), type_spec.name);
            }
            // Emit nested types with proper newline spacing between definitions
            for (int i = 0; i < type_spec.nested_types.size; i++) {
                if (i > 0 || !type_spec.methods.is_empty || !type_spec.fields.is_empty || !type_spec.properties.is_empty) {
                    emit ("\n");
                }
                emit_type_spec (type_spec.nested_types.get (i));
            }

            if (type_spec.kind != TypeSpec.Kind.NAMESPACE && !enclosing_type_names.is_empty) {
                enclosing_type_names.remove_at (enclosing_type_names.size - 1);
            }

            current_namespace = previous_ns;
            decrease_indent ();
            emit ("}\n");
        }

        public void emit_property (PropertySpec prop_spec) {
            emit_attributes (prop_spec.attributes);
            emit_modifiers (prop_spec.modifiers);
            emit ("%s %s", lookup_name (prop_spec.type_name), prop_spec.name);
            emit (" {\n");
            increase_indent ();

            bool has_bodies = (prop_spec.get_body != null || prop_spec.set_body != null || prop_spec.construct_body != null);

            if (!has_bodies) {
            // Auto property with optional getter/setter modifiers
                emit_modifiers (prop_spec.get_modifiers);
                emit ("get; ");
                emit_modifiers (prop_spec.set_modifiers);
                emit ("set;");
            } else {
                if (prop_spec.get_body != null) {
                    emit_modifiers (prop_spec.get_modifiers);
                    emit ("get {\n");
                    increase_indent ();
                    emit_code_block (prop_spec.get_body);
                    decrease_indent ();
                    emit ("}\n");
                } else {
                    emit_modifiers (prop_spec.get_modifiers);
                    emit ("get;\n");
                }

                if (prop_spec.set_body != null) {
                    emit_modifiers (prop_spec.set_modifiers);
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
                emit (" construct set;");
            }

            if (prop_spec.default_value != null) {
                emit (" default = ");
                emit_code_block (prop_spec.default_value);
                emit (";");
            }
            if (!has_bodies) {
                emit ("\n");
            }
            decrease_indent ();
            emit ("}\n");
        }

        public void emit_method (MethodSpec method_spec, string enclosing_name = "") {
            emit_valadoc (method_spec.valadoc);
            emit_attributes (method_spec.annotations);
            emit_modifiers (method_spec.modifiers);

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

            if (!method_spec.type_variables.is_empty) {
                emit ("<");
                for (int i = 0; i < method_spec.type_variables.size; i++) {
                    if (i > 0)emit (", ");
                    emit (method_spec.type_variables.get (i).to_string ());
                }
                emit (">");
            }

            emit (" (");

            for (int i = 0; i < method_spec.parameters.size; i++) {
                if (i > 0)emit (", ");
                var param = method_spec.parameters.get (i);
                emit_attributes (param.annotations);
                emit_modifiers (param.modifiers);
                if (param.direction == ParameterSpec.Direction.OUT) {
                    emit ("out ");
                } else if (param.direction == ParameterSpec.Direction.REF) {
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
            }
            if (method_spec.variadic) {
                if (method_spec.parameters.size > 0) {
                    emit (", ");
                }
                emit ("...");
            }
            emit (")");

            if (!method_spec.throws_errors.is_empty) {
                emit (" throws ");
                var errs = new Gee.ArrayList<string>();
                foreach (var err in method_spec.throws_errors) {
                    errs.add (lookup_name (err));
                }
                emit ("%s", string.joinv (", ", (string[]) errs.to_array ()));
            }

            // Contract programming (requires / ensures)
            if (!method_spec.requires_contracts.is_empty) {
                foreach (var req in method_spec.requires_contracts) {
                    emit ("\n");
                    emit ("requires (");
                    emit_code_block (req);
                    emit (")");
                }
            }
            if (!method_spec.ensures_contracts.is_empty) {
                foreach (var ens in method_spec.ensures_contracts) {
                    emit ("\n");
                    emit ("ensures (");
                    emit_code_block (ens);
                    emit (")");
                }
            }

            if (method_spec.modifiers.contains (ValaModifier.ABSTRACT)) {
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
            emit_modifiers (signal_spec.modifiers);
            emit ("signal ");
            if (signal_spec.return_type != null) {
                emit ("%s ", lookup_name (signal_spec.return_type));
            } else {
                emit ("void ");
            }
            emit ("%s (", signal_spec.name);
            for (int i = 0; i < signal_spec.parameters.size; i++) {
                if (i > 0)emit (", ");
                var p = signal_spec.parameters.get (i);
                emit ("%s %s", lookup_name (p.type_name), p.name);
            }
            emit (");\n");
        }

        public void emit_field (FieldSpec field_spec) {
            emit_attributes (field_spec.annotations);
            emit_modifiers (field_spec.modifiers);
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
            var temp_writer = new ValaWriter (sb, _indent, usings);
            temp_writer.emit_code_block (valadoc);
            var doc_lines = sb.str.split ("\n");
            foreach (var line in doc_lines) {
                if (line != "") {
                    emit (" * %s\n", line);
                }
            }
            emit (" */\n");
        }

        public void emit_attributes (Gee.ArrayList<AttributeSpec> attributes) {
            foreach (var attr in attributes) {
                emit ("[%s", attr.name);
                if (!attr.arguments.is_empty) {
                    emit ("(");
                    int idx = 0;
                    foreach (var entry in attr.arguments.entries) {
                        if (idx > 0)emit (", ");
                        emit ("%s = ", entry.key);
                        emit_code_block (entry.value);
                        idx++;
                    }
                    emit (")");
                }
                emit ("]\n");
            }
        }

        public void emit_delegate (DelegateName delegate_spec) {
            emit_attributes (delegate_spec.annotations);
            emit ("delegate %s %s (", lookup_name (delegate_spec.return_type), delegate_spec.name);
            for (int i = 0; i < delegate_spec.parameters.size; i++) {
                if (i > 0)emit (", ");
                var param = delegate_spec.parameters.get (i);
                emit ("%s %s", lookup_name (param.type_name), param.name);
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
                    emit (" ");                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // wrapping space
                } else if (part == "$Z") {
                // zero-width space
                } else if (part == "$L" || part == "$S" || part == "$T" || part == "$N") {
                    if (arg_index < code_block.args.size) {
                        var val = code_block.args.get (arg_index++);
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
                    importable_types.add (cn.namespace_name);
                }
                res = cn.simple_name;
                bool collides = cn.simple_name != "" && enclosing_type_names.contains (cn.simple_name);
                if (collides || (cn.namespace_name != "" && !usings.contains (cn.namespace_name) && current_namespace != cn.namespace_name)) {
                    res = cn.canonical_name;
                }
            } else if (type is ParameterizedTypeName) {
                var ptn = (ParameterizedTypeName) type;
                var args_str = new Gee.ArrayList<string>();
                foreach (var arg in ptn.type_arguments) {
                    args_str.add (lookup_name (arg));
                }
                res = lookup_name (ptn.raw_type) + "<" + string.joinv (", ", (string[]) args_str.to_array ()) + ">";
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

        public void emit_modifiers (Gee.HashSet<ValaModifier> modifiers) {
            if (modifiers.is_empty)return;
            var access = new Gee.ArrayList<ValaModifier>();
            var remaining = new Gee.ArrayList<ValaModifier>();

            foreach (var m in modifiers) {
                if (m == ValaModifier.PUBLIC || m == ValaModifier.PROTECTED || m == ValaModifier.PRIVATE || m == ValaModifier.INTERNAL) {
                    access.add (m);
                } else {
                    remaining.add (m);
                }
            }

            foreach (var m in access) {
                emit ("%s ", modifier_to_string (m));
            }
            foreach (var m in remaining) {
                emit ("%s ", modifier_to_string (m));
            }
        }

        private string modifier_to_string (ValaModifier m) {
            switch (m) {
                case ValaModifier.PUBLIC : return "public";
                case ValaModifier.PRIVATE : return "private";
                case ValaModifier.PROTECTED: return "protected";
                case ValaModifier.INTERNAL: return "internal";
                case ValaModifier.STATIC: return "static";
                case ValaModifier.ABSTRACT: return "abstract";
                case ValaModifier.VIRTUAL: return "virtual";
                case ValaModifier.OVERRIDE: return "override";
                case ValaModifier.SEALED: return "sealed";
                case ValaModifier.NEW: return "new";
                case ValaModifier.ASYNC: return "async";
                case ValaModifier.YIELD: return "yield";
                case ValaModifier.OWNED: return "owned";
                case ValaModifier.UNOWNED: return "unowned";
                case ValaModifier.WEAK: return "weak";
                case ValaModifier.CONST: return "const";
                case ValaModifier.DYNAMIC: return "dynamic";
                case ValaModifier.EXTERN: return "extern";
                case ValaModifier.INLINE: return "inline";
                case ValaModifier.PARTIAL: return "partial";
                case ValaModifier.VOLATILE: return "volatile";
                default: return "";
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
                out_builder.append (_indent);
            }
        }

    }

}
