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

    public class FieldSpec : GLib.Object {

        public string name { get; private set; }
        public TypeName type_name { get; private set; }
        public Gee.ArrayList<AttributeSpec> annotations { get; private set; }
        public Visibility visibility { get; private set; }
        public Gee.HashSet<SymbolModifier> modifiers { get; private set; }
        public CodeBlock ? initializer { get; private set; }

        private FieldSpec (Builder builder) {
            this.name = builder.name;
            this.type_name = builder.type_name;
            this.visibility = builder.vis;
            this.annotations = new Gee.ArrayList<AttributeSpec>();
            this.annotations.add_all (builder.annotations);
            this.modifiers = new Gee.HashSet<SymbolModifier>();
            this.modifiers.add_all (builder.modifiers);
            this.initializer = builder.initializer_block;
        }

        public static Builder builder (TypeName type_name, string name) {
            return new Builder (type_name, name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public TypeName type_name { get; private set; }
            public Visibility vis { get; private set; }
            public Gee.ArrayList<AttributeSpec> annotations { get; private set; }
            public Gee.HashSet<SymbolModifier> modifiers { get; private set; }
            public CodeBlock ? initializer_block { get; private set; }

            public Builder (TypeName type_name, string name) {
                this.type_name = type_name;
                this.name = name;
                this.vis = Visibility.NONE;
                this.annotations = new Gee.ArrayList<AttributeSpec>();
                this.modifiers = new Gee.HashSet<SymbolModifier>();
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

            public Builder initializer (string format, ...) {
                var va = va_list ();
                this.initializer_block = CodeBlock.of_valist (format, va);
                return this;
            }

            public FieldSpec build () {
                foreach (var m in modifiers) {
                    if (!m.targets_field ()) {
                        warning ("Modifier '%s' is not applicable to fields.", m.to_string ());
                    }
                }

                int memory_management_count = 0;
                if (type_name.is_owned)memory_management_count++;
                if (type_name.is_unowned)memory_management_count++;
                if (type_name.is_weak)memory_management_count++;

                if (memory_management_count > 1) {
                    error ("Field can only have one of OWNED, UNOWNED, or WEAK modifiers.");
                }

                return new FieldSpec (this);
            }

        }
    }

}
