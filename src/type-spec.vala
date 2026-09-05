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

    public class TypeSpec : Nameable, GLib.Object {

        public enum Kind {
            CLASS,
            STRUCT,
            INTERFACE,
            ENUM,
            ERROR_DOMAIN,
            NAMESPACE
        }

        public Kind kind { get; private set; }
        public string name { get; protected set; }
        public unowned GLib.List<AttributeSpec> attributes { get; private set; }
        public string? comment { get; private set; }
        public CodeBlock? valadoc { get; private set; }
        public unowned GLib.List<TypeVariableName> type_variables { get; private set; }
        public TypeName? superclass { get; private set; }
        public unowned GLib.List<TypeName> superinterfaces { get; private set; }
        public unowned GLib.List<MethodSpec> methods { get; private set; }
        public unowned GLib.List<FieldSpec> fields { get; private set; }
        public unowned GLib.List<PropertySpec> properties { get; private set; }
        public unowned GLib.List<SignalSpec> signals { get; private set; }
        public unowned GLib.List<TypeSpec> nested_types { get; private set; }
        public unowned GLib.List<string> error_codes { get; private set; }
        public unowned GLib.List<EnumConstantSpec> enum_constants { get; private set; }
        public CodeBlock? construct_block { get; private set; }
        public CodeBlock? class_construct_block { get; private set; }
        public CodeBlock? static_construct_block { get; private set; }
        public Visibility visibility { get; private set; }
        public unowned GLib.List<SymbolModifier> modifiers { get; private set; }

        private TypeSpec (Builder builder) {
            this.kind = builder.kind;
            this.name = builder.name;
            this.visibility = builder.vis;
            this.attributes = new GLib.List<AttributeSpec>();
            foreach (var a in builder.attributes) {
                this.attributes.append (a);
            }
            this.modifiers = new GLib.List<SymbolModifier>();
            foreach (var m in builder.modifiers) {
                this.modifiers.append (m);
            }
            this.comment = builder.comment;
            this.valadoc = builder.valadoc.build ();
            this.type_variables = new GLib.List<TypeVariableName>();
            foreach (var tv in builder.type_variables) {
                this.type_variables.append (tv);
            }
            this.superclass = builder.super_class;
            this.superinterfaces = new GLib.List<TypeName>();
            foreach (var si in builder.superinterfaces) {
                this.superinterfaces.append (si);
            }
            this.methods = new GLib.List<MethodSpec>();
            foreach (var m in builder.methods) {
                this.methods.append (m);
            }
            this.fields = new GLib.List<FieldSpec>();
            foreach (var f in builder.fields) {
                this.fields.append (f);
            }
            this.properties = new GLib.List<PropertySpec>();
            foreach (var p in builder.properties) {
                this.properties.append (p);
            }
            this.signals = new GLib.List<SignalSpec>();
            foreach (var sig in builder.signals) {
                this.signals.append (sig);
            }
            this.nested_types = new GLib.List<TypeSpec>();
            foreach (var nt in builder.nested_types) {
                this.nested_types.append (nt);
            }
            this.error_codes = new GLib.List<string>();
            foreach (var ec in builder.error_codes) {
                this.error_codes.append (ec);
            }
            this.enum_constants = new GLib.List<EnumConstantSpec>();
            foreach (var enc in builder.enum_constants) {
                this.enum_constants.append (enc);
            }
            this.construct_block = builder.construct_code_block;
            this.class_construct_block = builder.class_construct_code_block;
            this.static_construct_block = builder.static_construct_code_block;
        }

        public static Builder class_builder (string name) {
            return new Builder (Kind.CLASS, name);
        }

        public static Builder struct_builder (string name) {
            return new Builder (Kind.STRUCT, name);
        }

        public static Builder interface_builder (string name) {
            return new Builder (Kind.INTERFACE, name);
        }

        public static EnumSpec.Builder enum_builder (string name) {
            return EnumSpec.builder (name);
        }

        public static ErrorDomainSpec.Builder error_domain_builder (string name) {
            return ErrorDomainSpec.builder (name);
        }

        public static Builder namespace_builder (string name) {
            return new Builder (Kind.NAMESPACE, name);
        }

        public class Builder : GLib.Object {
            public Kind kind { get; private set; }
            public string name { get; private set; }
            public Visibility vis { get; private set; }
            public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
            public unowned GLib.List<AttributeSpec> attributes { get; private set; }
            public string? comment { get; private set; }
            public CodeBlock.Builder valadoc { get; private set; }
            public unowned GLib.List<TypeVariableName> type_variables { get; private set; }
            public TypeName? super_class { get; private set; }
            public unowned GLib.List<TypeName> superinterfaces { get; private set; }
            public unowned GLib.List<MethodSpec> methods { get; private set; }
            public unowned GLib.List<FieldSpec> fields { get; private set; }
            public unowned GLib.List<PropertySpec> properties { get; private set; }
            public unowned GLib.List<SignalSpec> signals { get; private set; }
            public unowned GLib.List<TypeSpec> nested_types { get; private set; }
            public unowned GLib.List<string> error_codes { get; private set; }
            public unowned GLib.List<EnumConstantSpec> enum_constants { get; private set; }
            public CodeBlock? construct_code_block { get; private set; }
            public CodeBlock? class_construct_code_block { get; private set; }
            public CodeBlock? static_construct_code_block { get; private set; }

            public Builder (Kind kind, string name) {
                this.kind = kind;
                this.name = name;
                this.vis = Visibility.NONE;
                this.attributes = new GLib.List<AttributeSpec>();
                this.modifiers = new GLib.List<SymbolModifier>();
                this.valadoc = new CodeBlock.Builder ();
                this.type_variables = new GLib.List<TypeVariableName>();
                this.superinterfaces = new GLib.List<TypeName>();
                this.methods = new GLib.List<MethodSpec>();
                this.fields = new GLib.List<FieldSpec>();
                this.properties = new GLib.List<PropertySpec>();
                this.signals = new GLib.List<SignalSpec>();
                this.nested_types = new GLib.List<TypeSpec>();
                this.error_codes = new GLib.List<string>();
                this.enum_constants = new GLib.List<EnumConstantSpec>();
            }

            public Builder add_comment (string format, ...) {
                var va = va_list ();
                return add_comment_valist (format, va);
            }

            public Builder add_comment_valist (string format, va_list va) {
                string formatted = format.vprintf (va);
                if (this.comment == null) {
                    this.comment = formatted;
                } else {
                    this.comment += "\n" + formatted;
                }
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

            public Builder add_type_variable (TypeVariableName type_variable) {
                this.type_variables.append (type_variable);
                return this;
            }

            public Builder add_error_code (string error_code) {
                this.error_codes.append (error_code);
                return this;
            }

            public Builder add_enum_constant (string name, int? value = null) {
                this.enum_constants.append (new EnumConstantSpec (name, value));
                return this;
            }

            public Builder add_enum_constant_spec (EnumConstantSpec enum_constant) {
                this.enum_constants.append (enum_constant);
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                this.attributes.append (attribute);
                return this;
            }

            public Builder add_valadoc (string format, ...) {
                var va = va_list ();
                this.valadoc.add_valist (format, va);
                return this;
            }

            public Builder add_valadoc_valist (string format, va_list va) {
                this.valadoc.add_valist (format, va);
                return this;
            }

            public Builder add_valadoc_spec (ValadocSpec doc) {
                this.valadoc.add_code (doc.to_code_block ());
                return this;
            }

            public Builder superclass (TypeName superclass) {
                this.super_class = superclass;
                return this;
            }

            public Builder prerequisite (TypeName prerequisite) {
                this.super_class = prerequisite;
                return this;
            }

            public Builder add_superinterface (TypeName superinterface) {
                this.superinterfaces.append (superinterface);
                return this;
            }

            public Builder add_prerequisite (TypeName prerequisite) {
                this.superinterfaces.append (prerequisite);
                return this;
            }

            public Builder add_method (MethodSpec method) {
                this.methods.append (method);
                return this;
            }

            public Builder add_field (FieldSpec field) {
                this.fields.append (field);
                return this;
            }

            public Builder add_property (PropertySpec prop) {
                this.properties.append (prop);
                return this;
            }

            public Builder add_signal (SignalSpec signal) {
                this.signals.append (signal);
                return this;
            }

            public Builder add_type (TypeSpec type) {
                this.nested_types.append (type);
                return this;
            }

            public Builder set_construct_block (CodeBlock block) {
                this.construct_code_block = block;
                return this;
            }

            public Builder set_class_construct_block (CodeBlock block) {
                this.class_construct_code_block = block;
                return this;
            }

            public Builder set_static_construct_block (CodeBlock block) {
                this.static_construct_code_block = block;
                return this;
            }

            public TypeSpec build () {
                Target target = Target.CLASS;
                if (kind == Kind.INTERFACE) target = Target.INTERFACE;
                else if (kind == Kind.STRUCT) target = Target.STRUCT;
                else if (kind == Kind.ENUM) target = Target.ENUM;

                foreach (var m in modifiers) {
                    if (!m.applies_to (target)) {
                        warning ("Modifier '%s' is not applicable to %s.", m.to_string (), kind.to_string ());
                    }
                }

                bool has_abstract_method = false;
                foreach (var method in methods) {
                    if (method.modifiers.find (SymbolModifier.ABSTRACT) != null) {
                        has_abstract_method = true;
                        break;
                    }
                }

                if (has_abstract_method && modifiers.find (SymbolModifier.ABSTRACT) == null && kind == Kind.CLASS) {
                    error ("class with abstract methods must be abstract");
                }

                return new TypeSpec (this);
            }

        }
    }

}
