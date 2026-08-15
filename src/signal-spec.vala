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

    public class SignalSpec : GLib.Object {

        public string name { get; private set; }
        public TypeName? return_type { get; private set; }
        public Gee.ArrayList<ParameterSpec> parameters { get; private set; }
        public Gee.HashSet<ValaModifier> modifiers { get; private set; }
        public Gee.ArrayList<AttributeSpec> attributes { get; private set; }

        private SignalSpec (Builder builder) {
            this.name = builder.name;
            this.return_type = builder.return_type;
            this.parameters = new Gee.ArrayList<ParameterSpec>();
            this.parameters.add_all (builder.parameters);
            this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            this.modifiers.add_all (builder.modifiers);
            this.attributes = new Gee.ArrayList<AttributeSpec>();
            this.attributes.add_all (builder.attributes);
        }

        public static Builder builder(string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName? return_type { get; private set; }
            public Gee.ArrayList<ParameterSpec> parameters { get; private set; }
            public Gee.HashSet<ValaModifier> modifiers { get; private set; }
            public Gee.ArrayList<AttributeSpec> attributes { get; private set; }

            public Builder (string name) {
                this.name = name;
                this.parameters = new Gee.ArrayList<ParameterSpec>();
                this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
                this.attributes = new Gee.ArrayList<AttributeSpec>();
            }

            public Builder returns(TypeName return_type) {
                this.return_type = return_type;
                return this;
            }

            public Builder add_parameter(ParameterSpec parameter) {
                this.parameters.add (parameter);
                return this;
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

            public SignalSpec build() {
                return new SignalSpec (this);
            }

        }
    }

}
