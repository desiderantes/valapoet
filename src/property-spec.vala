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

    public class PropertySpec : GLib.Object {

        public string name { get; private set; }
        public TypeName type_name { get; private set; }
        public Gee.ArrayList<AttributeSpec> attributes { get; private set; }
        public Visibility visibility { get; private set; }
        public Gee.HashSet<SymbolModifier> modifiers { get; private set; }
        public CodeBlock? get_body { get; private set; }
        public Visibility get_visibility { get; private set; }
        public Gee.HashSet<SymbolModifier> get_modifiers { get; private set; }
        public CodeBlock? set_body { get; private set; }
        public Visibility set_visibility { get; private set; }
        public Gee.HashSet<SymbolModifier> set_modifiers { get; private set; }
        public CodeBlock? construct_body { get; private set; }
        public bool is_construct_set { get; private set; }
        public CodeBlock? default_value { get; private set; }
        public bool is_auto { get; private set; }
        public bool is_read_only { get; private set; }
        public bool is_construct_only { get; private set; }

        private PropertySpec (Builder builder) {
            this.name = builder.name;
            this.type_name = builder.type_name;
            this.visibility = builder.vis;
            this.attributes = new Gee.ArrayList<AttributeSpec>();
            this.attributes.add_all (builder.attributes);
            this.modifiers = new Gee.HashSet<SymbolModifier>();
            this.modifiers.add_all (builder.modifiers);
            this.get_body = builder.get_body_block;
            this.get_visibility = builder.get_vis;
            this.get_modifiers = new Gee.HashSet<SymbolModifier>();
            this.get_modifiers.add_all (builder.get_modifiers);
            this.set_body = builder.set_body_block;
            this.set_visibility = builder.set_vis;
            this.set_modifiers = new Gee.HashSet<SymbolModifier>();
            this.set_modifiers.add_all (builder.set_modifiers);
            this.construct_body = builder.construct_body_block;
            this.is_construct_set = builder.is_construct_set;
            this.default_value = builder.default_val;
            this.is_auto = builder.is_auto;
            this.is_read_only = builder.is_readonly;
            this.is_construct_only = builder.is_construct_only;
        }

        public static Builder builder (TypeName type_name, string name) {
            return new Builder (type_name, name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName type_name { get; private set; }
            public Visibility vis { get; private set; }
            public Gee.ArrayList<AttributeSpec> attributes { get; private set; }
            public Gee.HashSet<SymbolModifier> modifiers { get; private set; }
            public CodeBlock? get_body_block { get; private set; }
            public Visibility get_vis { get; private set; }
            public Gee.HashSet<SymbolModifier> get_modifiers { get; private set; }
            public CodeBlock? set_body_block { get; private set; }
            public Visibility set_vis { get; private set; }
            public Gee.HashSet<SymbolModifier> set_modifiers { get; private set; }
            public CodeBlock? construct_body_block { get; private set; }
            public bool is_construct_set { get; private set; }
            public CodeBlock? default_val { get; private set; }
            public bool is_auto { get; private set; }
            public bool is_readonly { get; private set; }
            public bool is_construct_only { get; private set; }

            public Builder (TypeName type_name, string name) {
                this.type_name = type_name;
                this.name = name;
                this.vis = Visibility.NONE;
                this.get_vis = Visibility.NONE;
                this.set_vis = Visibility.NONE;
                this.attributes = new Gee.ArrayList<AttributeSpec>();
                this.modifiers = new Gee.HashSet<SymbolModifier>();
                this.get_modifiers = new Gee.HashSet<SymbolModifier>();
                this.set_modifiers = new Gee.HashSet<SymbolModifier>();
            }

            public Builder add_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.modifiers.add (m);
                }
                return this;
            }

            public Builder visibility (Visibility vis) {
                this.vis = vis;
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                this.attributes.add (attribute);
                return this;
            }

            public Builder get_body (CodeBlock body) {
                this.get_body_block = body;
                return this;
            }

            public Builder add_get_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.get_modifiers.add (m);
                }
                return this;
            }

            public Builder set_body (CodeBlock body) {
                this.set_body_block = body;
                return this;
            }

            public Builder add_set_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.set_modifiers.add (m);
                }
                return this;
            }

            public Builder construct_body (CodeBlock body) {
                this.construct_body_block = body;
                return this;
            }

            public Builder construct_set (bool is_construct_set = true) {
                this.is_construct_set = is_construct_set;
                return this;
            }

            public Builder default_value (string format, ...) {
                var va = va_list ();
                this.default_val = CodeBlock.of_valist (format, va);
                return this;
            }

            public Builder auto () {
                this.is_auto = true;
                return this;
            }

            public Builder read_only () {
                this.is_readonly = true;
                return this;
            }

            public Builder private_set () {
                this.set_vis = Visibility.PRIVATE;
                return this;
            }

            public Builder protected_set () {
                this.set_vis = Visibility.PROTECTED;
                return this;
            }

            public Builder construct_only () {
                this.is_construct_only = true;
                return this;
            }

            public PropertySpec build () {
                foreach (var m in modifiers) {
                    if (!m.targets_property ()) {
                        warning ("Modifier '%s' is not applicable to properties.", m.to_string ());
                    }
                }
                return new PropertySpec (this);
            }

        }
    }

}
