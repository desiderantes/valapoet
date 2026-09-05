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

    public class EnumConstantSpec : Nameable, GLib.Object {
        public string name { get; protected set; }
        public int? value { get; private set; }
        public string? comment { get; private set; }
        public CodeBlock? valadoc { get; private set; }

        public EnumConstantSpec (string name, int? value = null, string? comment = null, CodeBlock? valadoc = null) {
            this.name = name;
            this.value = value;
            this.comment = comment;
            this.valadoc = valadoc;
        }

    }

    public class EnumSpec : GLib.Object {

        public static Builder builder (string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            private TypeSpec.Builder inner_builder;

            public Builder (string name) {
                this.inner_builder = new TypeSpec.Builder (TypeSpec.Kind.ENUM, name);
            }

            public Builder visibility (Visibility vis) {
                inner_builder.visibility (vis);
                return this;
            }

            public Builder add_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    inner_builder.add_modifiers (m);
                }
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                inner_builder.add_attribute (attribute);
                return this;
            }

            public Builder add_comment (string format, ...) {
                var va = va_list ();
                inner_builder.add_comment_valist (format, va);
                return this;
            }

            public Builder add_valadoc (string format, ...) {
                var va = va_list ();
                inner_builder.add_valadoc_valist (format, va);
                return this;
            }

            public Builder add_valadoc_spec (ValadocSpec doc) {
                inner_builder.add_valadoc_spec (doc);
                return this;
            }

            public Builder add_constant (string name, int? value = null) {
                inner_builder.add_enum_constant (name, value);
                return this;
            }

            public Builder add_enum_constant (string name, int? value = null) {
                inner_builder.add_enum_constant (name, value);
                return this;
            }

            public Builder add_method (MethodSpec method) {
                inner_builder.add_method (method);
                return this;
            }

            public TypeSpec build () {
                return inner_builder.build ();
            }
        }
    }

    public class ErrorDomainSpec : GLib.Object {

        public static Builder builder (string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            private TypeSpec.Builder inner_builder;

            public Builder (string name) {
                this.inner_builder = new TypeSpec.Builder (TypeSpec.Kind.ERROR_DOMAIN, name);
            }

            public Builder visibility (Visibility vis) {
                inner_builder.visibility (vis);
                return this;
            }

            public Builder add_modifiers (params SymbolModifier[] modifiers) {
                foreach (var m in modifiers) {
                    inner_builder.add_modifiers (m);
                }
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                inner_builder.add_attribute (attribute);
                return this;
            }

            public Builder add_comment (string format, ...) {
                var va = va_list ();
                inner_builder.add_comment_valist (format, va);
                return this;
            }

            public Builder add_valadoc (string format, ...) {
                var va = va_list ();
                inner_builder.add_valadoc_valist (format, va);
                return this;
            }

            public Builder add_valadoc_spec (ValadocSpec doc) {
                inner_builder.add_valadoc_spec (doc);
                return this;
            }

            public Builder add_error_code (string name) {
                inner_builder.add_error_code (name);
                return this;
            }

            public TypeSpec build () {
                return inner_builder.build ();
            }
        }
    }

}
