/*
 * Copyright (C) 2015 Square, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
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

    /**
     * A fragment of a .vala file, potentially containing declarations, statements, and documentation.
     * Code blocks are not necessarily well-formed Vala code, and are not validated.
     */
    public class CodeBlock : GLib.Object {
        /** A heterogeneous list containing string literals and value placeholders. */
        public unowned GLib.List<string> format_parts { get; private set; }
        public unowned GLib.List<Value ?> args { get; private set; }

        public CodeBlock (Builder builder) {
            this.format_parts = new GLib.List<string>();
            foreach (var fp in builder.format_parts) {
                this.format_parts.append (fp);
            }
            this.args = new GLib.List<Value ?>();
            foreach (var a in builder.args) {
                this.args.append (a);
            }
        }

        public static CodeBlock of (string format, ...) {
            var va = va_list ();
            return of_valist (format, va);
        }

        public static CodeBlock of_valist (string format, va_list va) {
            var builder = new Builder ();
            builder.add_valist (format, va);
            return builder.build ();
        }

        public bool is_empty () {
            return format_parts == null || format_parts.length () == 0;
        }

        public static Builder builder () {
            return new Builder ();
        }

        public class Builder : GLib.Object {
            public GLib.List<string> format_parts = new GLib.List<string>();
            public GLib.List<Value ?> args = new GLib.List<Value ?>();

            public Builder add (string format, ...) {
                var va = va_list ();
                return add_valist (format, va);
            }

            public Builder add_valist (string format, va_list va) {
                int len = format.length;
                int p = 0;
                var current = new StringBuilder ();

                while (p < len) {
                    char c = format[p];
                    if ((c == '$' || c == '%') && p + 1 < len) {
                        char next = format[p + 1];
                        if (next == '$' || next == '%') {
                            current.append_c (c);
                            p += 2;
                            continue;
                        }

                        if (next == 'L' || next == 'S' || next == 'T' || next == 'N') {
                            if (current.len > 0) {
                                format_parts.append (current.str);
                                current.truncate ();
                            }
                            format_parts.append ("$" + next.to_string ());

                            Value val = Value (typeof (Object));
                            if (next == 'S') {
                                string s = va.arg<string> ();
                                val = Value (typeof (string));
                                val.set_string (s);
                            } else {
                                Object obj = va.arg<Object> ();
                                val.set_object (obj);
                            }
                            args.append (val);
                            p += 2;
                            continue;
                        } else if (c == '$' && (next == '>' || next == '<' || next == '[' || next == ']')) {
                            if (current.len > 0) {
                                format_parts.append (current.str);
                                current.truncate ();
                            }
                            format_parts.append ("$" + next.to_string ());
                            p += 2;
                            continue;
                        }
                    }
                    current.append_c (c);
                    p++;
                }

                if (current.len > 0) {
                    format_parts.append (current.str);
                }
                return this;
            }

            public Builder add_statement (string format, ...) {
                var va = va_list ();
                return add_statement_valist (format, va);
            }

            public Builder add_statement_valist (string format, va_list va) {
                add ("$[");
                add_valist (format, va);
                string trimmed = format.strip ();
                if (!trimmed.has_suffix (";") && !trimmed.has_suffix (":") && !trimmed.has_suffix ("{") && !trimmed.has_suffix ("}")) {
                    add (";");
                }
                add ("\n$]");
                return this;
            }

            public Builder add_raw (string code) {
                format_parts.append (code);
                return this;
            }

            public Builder add_statement_raw (string code) {
                add ("$[");
                add_raw (code);
                string trimmed = code.strip ();
                if (!trimmed.has_suffix (";") && !trimmed.has_suffix (":") && !trimmed.has_suffix ("{") && !trimmed.has_suffix ("}")) {
                    add (";");
                }
                add ("\n$]");
                return this;
            }

            public Builder begin_control_flow (string format, ...) {
                var va = va_list ();
                return begin_control_flow_valist (format, va);
            }

            public Builder begin_control_flow_valist (string format, va_list va) {
                add_valist (format + " {\n", va);
                indent ();
                return this;
            }

            public Builder next_control_flow (string format, ...) {
                var va = va_list ();
                return next_control_flow_valist (format, va);
            }

            public Builder next_control_flow_valist (string format, va_list va) {
                unindent ();
                add_valist ("} " + format + " {\n", va);
                indent ();
                return this;
            }

            public Builder end_control_flow () {
                unindent ();
                add ("}\n");
                return this;
            }

            public Builder add_code (CodeBlock code_block) {
                foreach (var fp in code_block.format_parts) {
                    format_parts.append (fp);
                }
                foreach (var a in code_block.args) {
                    args.append (a);
                }
                return this;
            }

            public Builder indent () {
                this.format_parts.append ("$>");
                return this;
            }

            public Builder unindent () {
                this.format_parts.append ("$<");
                return this;
            }

            public bool is_empty () {
                return format_parts == null || format_parts.length () == 0;
            }

            public CodeBlock build () {
                return new CodeBlock (this);
            }

        }
    }

}
