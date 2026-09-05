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

    public class SignalSpec : Nameable, GLib.Object {

        public string name { get; protected set; }
        public TypeName? return_type { get; private set; }
        public unowned GLib.List<ParameterSpec> parameters { get; private set; }
        public Visibility visibility { get; private set; }
        public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
        public unowned GLib.List<AttributeSpec> attributes { get; private set; }
        public string? comment { get; private set; }
        public CodeBlock? valadoc { get; private set; }

        private SignalSpec (Builder builder) {
            this.name = builder.name;
            this.return_type = builder.return_type;
            this.visibility = builder.vis;
            this.comment = builder.comment;
            this.valadoc = builder.valadoc.build ();
            this.parameters = new GLib.List<ParameterSpec>();
            foreach (var p in builder.parameters) {
                this.parameters.append (p);
            }
            this.modifiers = new GLib.List<SymbolModifier>();
            foreach (var m in builder.modifiers) {
                this.modifiers.append (m);
            }
            this.attributes = new GLib.List<AttributeSpec>();
            foreach (var a in builder.attributes) {
                this.attributes.append (a);
            }
        }

        public static Builder builder (string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName? return_type { get; private set; }
            public unowned GLib.List<ParameterSpec> parameters { get; private set; }
            public Visibility vis { get; private set; }
            public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
            public unowned GLib.List<AttributeSpec> attributes { get; private set; }
            public string? comment { get; private set; }
            public CodeBlock.Builder valadoc { get; private set; }

            public Builder (string name) {
                this.name = name;
                this.vis = Visibility.NONE;
                this.parameters = new GLib.List<ParameterSpec>();
                this.modifiers = new GLib.List<SymbolModifier>();
                this.attributes = new GLib.List<AttributeSpec>();
                this.valadoc = new CodeBlock.Builder ();
            }

            public Builder add_comment (string format, ...) {
                var va = va_list ();
                string formatted = format.vprintf (va);
                if (this.comment == null) {
                    this.comment = formatted;
                } else {
                    this.comment += "\n" + formatted;
                }
                return this;
            }

            public Builder add_valadoc (string format, ...) {
                var va = va_list ();
                string formatted = format.vprintf (va);
                this.valadoc.add_raw (formatted);
                return this;
            }

            public Builder returns (TypeName return_type) {
                this.return_type = return_type;
                return this;
            }

            public Builder add_parameter (ParameterSpec parameter) {
                this.parameters.append (parameter);
                return this;
            }

            public Builder add_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    if (this.modifiers.find (m) == null) {
                        this.modifiers.append (m);
                    }
                }
                return this;
            }

            public Builder visibility (Visibility vis) {
                this.vis = vis;
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                this.attributes.append (attribute);
                return this;
            }

            public SignalSpec build () {
                return new SignalSpec (this);
            }

        }
    }

}
