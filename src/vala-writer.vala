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

    public partial class ValaWriter : GLib.Object {

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

            if (type.is_unowned) res = "unowned " + res;
            if (type.is_owned) res = "owned " + res;
            if (type.is_weak) res = "weak " + res;
            if (type.is_nullable) res += "?";
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
