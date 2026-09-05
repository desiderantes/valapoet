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

    public class ParameterSpec : Nameable, GLib.Object {



        public enum Direction {
            IN,
            OUT,
            REF
        }

        public string name { get; protected set; }
        public TypeName type_name { get; private set; }
        public unowned GLib.List<AttributeSpec> attributes { get; private set; }
        public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
        public ParameterDirection direction { get; private set; }
        public CodeBlock? default_value { get; private set; }
        public bool is_params { get; private set; }

        private ParameterSpec (Builder builder) {
            this.name = builder.name;
            this.type_name = builder.type_name;
            this.attributes = new GLib.List<AttributeSpec>();
            foreach (var a in builder.attributes) {
                this.attributes.append (a);
            }
            this.modifiers = new GLib.List<SymbolModifier>();
            foreach (var m in builder.modifiers) {
                this.modifiers.append (m);
            }
            this.direction = builder.param_dir;
            this.default_value = builder.default_val;
            this.is_params = builder.is_params;
        }

        public static Builder builder (TypeName type_name, string name) {
            return new Builder (type_name, name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName type_name { get; private set; }
            public unowned GLib.List<AttributeSpec> attributes { get; private set; }
            public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
            public ParameterDirection param_dir { get; private set; }
            public CodeBlock? default_val { get; private set; }
            public bool is_params { get; private set; }

            public Builder (TypeName type_name, string name) {
                this.type_name = type_name;
                this.name = name;
                this.attributes = new GLib.List<AttributeSpec>();
                this.modifiers = new GLib.List<SymbolModifier>();
                this.param_dir = ParameterDirection.IN;
            }

            public Builder add_modifiers (params SymbolModifier[] modifiers) {
                foreach (var mod in modifiers) {
                    if (this.modifiers.find (mod) == null) {
                        this.modifiers.append (mod);
                    }
                }
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                this.attributes.append (attribute);
                return this;
            }

            public Builder direction (ParameterDirection dir) {
                this.param_dir = dir;
                return this;
            }

            public Builder default_value (string format, ...) {
                var va = va_list ();
                this.default_val = CodeBlock.of_valist (format, va);
                return this;
            }

            public Builder @params (bool is_params = true) {
                this.is_params = is_params;
                return this;
            }

            public ParameterSpec build () {
                return new ParameterSpec (this);
            }

        }
    }

}
