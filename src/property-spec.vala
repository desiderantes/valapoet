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
        public Gee.HashSet<ValaModifier> modifiers { get; private set; }
        public CodeBlock? get_body { get; private set; }
        public Gee.HashSet<ValaModifier> get_modifiers { get; private set; }
        public CodeBlock? set_body { get; private set; }
        public Gee.HashSet<ValaModifier> set_modifiers { get; private set; }
        public CodeBlock? construct_body { get; private set; }
        public bool is_construct_set { get; private set; }
        public CodeBlock? default_value { get; private set; }
        public bool is_auto { get; private set; }

        private PropertySpec (Builder builder) {
            this.name = builder.name;
            this.type_name = builder.type_name;
            this.attributes = new Gee.ArrayList<AttributeSpec>();
            this.attributes.add_all (builder.attributes);
            this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            this.modifiers.add_all (builder.modifiers);
            this.get_body = builder.get_body_block;
            this.get_modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            this.get_modifiers.add_all (builder.get_modifiers);
            this.set_body = builder.set_body_block;
            this.set_modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            this.set_modifiers.add_all (builder.set_modifiers);
            this.construct_body = builder.construct_body_block;
            this.is_construct_set = builder.is_construct_set;
            this.default_value = builder.default_val;
            this.is_auto = builder.is_auto;
        }

        public static Builder builder(TypeName type_name,string name) {
            return new Builder (type_name,name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName type_name { get; private set; }
            public Gee.ArrayList<AttributeSpec> attributes { get; private set; }
            public Gee.HashSet<ValaModifier> modifiers { get; private set; }
            public CodeBlock? get_body_block { get; private set; }
            public Gee.HashSet<ValaModifier> get_modifiers { get; private set; }
            public CodeBlock? set_body_block { get; private set; }
            public Gee.HashSet<ValaModifier> set_modifiers { get; private set; }
            public CodeBlock? construct_body_block { get; private set; }
            public bool is_construct_set { get; private set; }
            public CodeBlock? default_val { get; private set; }
            public bool is_auto { get; private set; }

            public Builder (TypeName type_name,string name) {
                this.type_name = type_name;
                this.name = name;
                this.attributes = new Gee.ArrayList<AttributeSpec>();
                this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
                this.get_modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
                this.set_modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            }

            public Builder add_modifiers(params ValaModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.modifiers.add (m);
                }
                return this;
            }

            public Builder add_attribute(AttributeSpec attribute) {
                this.attributes.add (attribute);
                return this;
            }

            public Builder get_body(CodeBlock body) {
                this.get_body_block = body;
                return this;
            }

            public Builder add_get_modifiers(params ValaModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.get_modifiers.add (m);
                }
                return this;
            }

            public Builder set_body(CodeBlock body) {
                this.set_body_block = body;
                return this;
            }

            public Builder add_set_modifiers(params ValaModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.set_modifiers.add (m);
                }
                return this;
            }

            public Builder construct_body(CodeBlock body) {
                this.construct_body_block = body;
                return this;
            }

            public Builder construct_set(bool is_construct_set = true) {
                this.is_construct_set = is_construct_set;
                return this;
            }

            public Builder default_value(string format,...) {
                var va = va_list ();
                this.default_val = CodeBlock.of_valist (format,va);
                return this;
            }

            public Builder auto() {
                this.is_auto = true;
                return this;
            }

            public PropertySpec build() {
                return new PropertySpec (this);
            }

        }
    }

}
