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

    public class ValaFile : GLib.Object {

        public Gee.ArrayList<Object> members { get; private set; }                                                                                                                      // Can contain TypeSpec, MethodSpec, or DelegateName
        public string indent { get; private set; }
        public Gee.HashSet<string> usings { get; private set; }

        private ValaFile (Builder builder) {
            this.members = new Gee.ArrayList<Object>();
            this.members.add_all (builder.members);
            this.indent = builder.indent_str;
            this.usings = new Gee.HashSet<string>();
            this.usings.add_all (builder.usings);
        }

        public void write_to (StringBuilder builder) {
            var writer = new ValaWriter (builder, this.indent);
            writer.emit_file (this);
        }

        public string to_string () {
            var builder = new StringBuilder ();
            write_to (builder);
            return builder.str;
        }

        public static Builder builder () {
            return new Builder ();
        }

        public class Builder : GLib.Object {
            public Gee.ArrayList<Object> members { get; private set; }
            public string indent_str { get; private set; }
            public Gee.HashSet<string> usings { get; private set; }

            public Builder () {
                this.members = new Gee.ArrayList<Object>();
                this.indent_str = "\t";                                                                                                                                                                                                                                                                                                                                                                                 // Vala standard
                this.usings = new Gee.HashSet<string>();
            }

            public Builder add_type (TypeSpec type_spec) {
                this.members.add (type_spec);
                return this;
            }

            public Builder set_namespace (TypeSpec namespace_spec) {
                this.members.add (namespace_spec);
                return this;
            }

            public Builder add_method (MethodSpec method_spec) {
                this.members.add (method_spec);
                return this;
            }

            public Builder add_delegate (DelegateName delegate_spec) {
                this.members.add (delegate_spec);
                return this;
            }

            public Builder add_using (string ns) {
                this.usings.add (ns);
                return this;
            }

            public Builder indent (string indent) {
                this.indent_str = indent;
                return this;
            }

            public ValaFile build () {
                return new ValaFile (this);
            }

        }
    }

}
