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

        public void emit_property (PropertySpec prop_spec) {
            emit_comment (prop_spec.comment);
            emit_valadoc (prop_spec.valadoc);
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
            emit_comment (method_spec.comment);
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
            emit_comment (signal_spec.comment);
            emit_valadoc (signal_spec.valadoc);
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
            emit_comment (field_spec.comment);
            emit_valadoc (field_spec.valadoc);
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

        public void emit_comment (string? comment) {
            if (comment == null || comment.strip () == "") return;
            var comment_lines = comment.split ("\n");
            foreach (var line in comment_lines) {
                if (line != "") {
                    emit ("// %s\n", line);
                }
            }
        }

        public void emit_valadoc (CodeBlock? valadoc) {
            if (valadoc == null || valadoc.is_empty ()) return;
            string doc_text = render_code_block_to_string (valadoc);
            emit ("/**\n");
            var doc_lines = doc_text.split ("\n");
            foreach (var line in doc_lines) {
                if (line != "") {
                    emit (" * %s\n", line);
                }
            }
            emit (" */\n");
        }

        private string render_code_block_to_string (CodeBlock code_block) {
            var sb = new StringBuilder ();
            int arg_index = 0;
            foreach (var part in code_block.format_parts) {
                if (part == "$>" || part == "$<" || part == "$[" || part == "$]" || part == "$Z") {
                    continue;
                } else if (part == "$W") {
                    sb.append_c (' ');
                } else if (part == "$L" || part == "$S" || part == "$T" || part == "$N") {
                    if (code_block.args != null && arg_index < code_block.args.length ()) {
                        unowned GLib.List<Value ?> node = code_block.args.nth (arg_index++);
                        var val = (node != null) ? node.data : null;
                        if (val != null) {
                            if (val.holds (typeof (string))) {
                                string str = val.get_string ();
                                if (part == "$S") {
                                    sb.append_printf ("\"%s\"", str.compress ());
                                } else {
                                    sb.append (str);
                                }
                            } else if (val.holds (typeof (Object))) {
                                Object? obj = val.get_object ();
                                if (obj != null) {
                                    if (part == "$T" && obj is TypeName) {
                                        sb.append (lookup_name ((TypeName) obj));
                                    } else if (part == "$N") {
                                        if (obj is MethodSpec) sb.append (((MethodSpec) obj).name);
                                        else if (obj is FieldSpec) sb.append (((FieldSpec) obj).name);
                                        else if (obj is PropertySpec) sb.append (((PropertySpec) obj).name);
                                        else if (obj is ParameterSpec) sb.append (((ParameterSpec) obj).name);
                                        else if (obj is TypeSpec) sb.append (((TypeSpec) obj).name);
                                        else if (obj is SignalSpec) sb.append (((SignalSpec) obj).name);
                                        else sb.append (obj.get_type ().name ());
                                    } else if (obj is CodeBlock) {
                                        sb.append (render_code_block_to_string ((CodeBlock) obj));
                                    } else if (obj is TypeName) {
                                        sb.append (lookup_name ((TypeName) obj));
                                    } else {
                                        sb.append (obj.get_type ().name ());
                                    }
                                }
                            }
                        }
                    }
                } else {
                    sb.append (part);
                }
            }
            return sb.str;
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

    }

}
