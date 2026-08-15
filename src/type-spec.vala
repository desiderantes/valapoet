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

    public static uint vala_modifier_hash(ValaModifier m) {
        return (uint) m;
    }

    public static bool vala_modifier_equal(ValaModifier a,ValaModifier b) {
        return a == b;
    }

    public class TypeSpec : GLib.Object {

        public enum Kind{
            CLASS,
            STRUCT,
            INTERFACE,
            ENUM,
            ERROR_DOMAIN,
            NAMESPACE
        }

        public Kind kind { get; private set; }
        public string name { get; private set; }
        public Gee.ArrayList<AttributeSpec> attributes { get; private set; }
        public Gee.HashSet<ValaModifier> modifiers { get; private set; }
        public CodeBlock? valadoc { get; private set; }
        public Gee.ArrayList<TypeVariableName> type_variables { get; private set; }
        public TypeName? superclass { get; private set; }
        public Gee.ArrayList<TypeName> superinterfaces { get; private set; }
        public Gee.ArrayList<MethodSpec> methods { get; private set; }
        public Gee.ArrayList<FieldSpec> fields { get; private set; }
        public Gee.ArrayList<PropertySpec> properties { get; private set; }
        public Gee.ArrayList<SignalSpec> signals { get; private set; }
        public Gee.ArrayList<TypeSpec> nested_types { get; private set; }
        public Gee.ArrayList<string> error_codes { get; private set; }
        public CodeBlock? construct_block { get; private set; }
        public CodeBlock? class_construct_block { get; private set; }
        public CodeBlock? static_construct_block { get; private set; }

        private TypeSpec (Builder builder) {
            this.kind = builder.kind;
            this.name = builder.name;
            this.attributes = new Gee.ArrayList<AttributeSpec>();
            this.attributes.add_all (builder.attributes);
            this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
            foreach (var m in builder.modifiers) {
                this.modifiers.add (m);
            }
            this.valadoc = builder.valadoc.build ();
            this.type_variables = new Gee.ArrayList<TypeVariableName>();
            this.type_variables.add_all (builder.type_variables);
            this.superclass = builder.super_class;
            this.superinterfaces = new Gee.ArrayList<TypeName>();
            this.superinterfaces.add_all (builder.superinterfaces);
            this.methods = new Gee.ArrayList<MethodSpec>();
            this.methods.add_all (builder.methods);
            this.fields = new Gee.ArrayList<FieldSpec>();
            this.fields.add_all (builder.fields);
            this.properties = new Gee.ArrayList<PropertySpec>();
            this.properties.add_all (builder.properties);
            this.signals = new Gee.ArrayList<SignalSpec>();
            this.signals.add_all (builder.signals);
            this.nested_types = new Gee.ArrayList<TypeSpec>();
            this.nested_types.add_all (builder.nested_types);
            this.error_codes = new Gee.ArrayList<string>();
            this.error_codes.add_all (builder.error_codes);
            this.construct_block = builder.construct_code_block;
            this.class_construct_block = builder.class_construct_code_block;
            this.static_construct_block = builder.static_construct_code_block;
        }

        public static Builder class_builder(string name) {
            return new Builder (Kind.CLASS,name);
        }

        public static Builder struct_builder(string name) {
            return new Builder (Kind.STRUCT,name);
        }

        public static Builder interface_builder(string name) {
            return new Builder (Kind.INTERFACE,name);
        }

        public static Builder enum_builder(string name) {
            return new Builder (Kind.ENUM,name);
        }

        public static Builder error_domain_builder(string name) {
            return new Builder (Kind.ERROR_DOMAIN,name);
        }

        public static Builder namespace_builder(string name) {
            return new Builder (Kind.NAMESPACE,name);
        }

        public class Builder : GLib.Object {
            public Kind kind { get; private set; }
            public string name { get; private set; }
            public Gee.ArrayList<AttributeSpec> attributes { get; private set; }
            public Gee.HashSet<ValaModifier> modifiers { get; private set; }
            public CodeBlock.Builder valadoc { get; private set; }
            public Gee.ArrayList<TypeVariableName> type_variables { get; private set; }
            public TypeName? super_class { get; private set; }
            public Gee.ArrayList<TypeName> superinterfaces { get; private set; }
            public Gee.ArrayList<MethodSpec> methods { get; private set; }
            public Gee.ArrayList<FieldSpec> fields { get; private set; }
            public Gee.ArrayList<PropertySpec> properties { get; private set; }
            public Gee.ArrayList<SignalSpec> signals { get; private set; }
            public Gee.ArrayList<TypeSpec> nested_types { get; private set; }
            public Gee.ArrayList<string> error_codes { get; private set; }
            public CodeBlock? construct_code_block { get; private set; }
            public CodeBlock? class_construct_code_block { get; private set; }
            public CodeBlock? static_construct_code_block { get; private set; }

            public Builder (Kind kind,string name) {
                this.kind = kind;
                this.name = name;
                this.attributes = new Gee.ArrayList<AttributeSpec>();
                this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash,vala_modifier_equal);
                this.valadoc = new CodeBlock.Builder ();
                this.type_variables = new Gee.ArrayList<TypeVariableName>();
                this.superinterfaces = new Gee.ArrayList<TypeName>();
                this.methods = new Gee.ArrayList<MethodSpec>();
                this.fields = new Gee.ArrayList<FieldSpec>();
                this.properties = new Gee.ArrayList<PropertySpec>();
                this.signals = new Gee.ArrayList<SignalSpec>();
                this.nested_types = new Gee.ArrayList<TypeSpec>();
                this.error_codes = new Gee.ArrayList<string>();
            }

            public Builder add_modifiers(params ValaModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.modifiers.add (m);
                }
                return this;
            }

            public Builder add_type_variable(TypeVariableName type_variable) {
                this.type_variables.add (type_variable);
                return this;
            }

            public Builder add_error_code(string error_code) {
                this.error_codes.add (error_code);
                return this;
            }

            public Builder add_attribute(AttributeSpec attribute) {
                this.attributes.add (attribute);
                return this;
            }

            public Builder add_valadoc(string format,...) {
                var va = va_list ();
                this.valadoc.add_valist (format,va);
                return this;
            }

            public Builder superclass(TypeName superclass) {
                this.super_class = superclass;
                return this;
            }

            public Builder add_method(MethodSpec method) {
                this.methods.add (method);
                return this;
            }

            public Builder add_field(FieldSpec field) {
                this.fields.add (field);
                return this;
            }

            public Builder add_property(PropertySpec prop) {
                this.properties.add (prop);
                return this;
            }

            public Builder add_signal(SignalSpec signal) {
                this.signals.add (signal);
                return this;
            }

            public Builder add_type(TypeSpec type) {
                this.nested_types.add (type);
                return this;
            }

            public Builder set_construct_block(CodeBlock block) {
                this.construct_code_block = block;
                return this;
            }

            public Builder set_class_construct_block(CodeBlock block) {
                this.class_construct_code_block = block;
                return this;
            }

            public Builder set_static_construct_block(CodeBlock block) {
                this.static_construct_code_block = block;
                return this;
            }

            public TypeSpec build() {
                bool has_abstract_method = false;
                foreach (var method in methods) {
                    if (method.modifiers.contains (ValaModifier.ABSTRACT)) {
                        has_abstract_method = true;
                        break;
                    }
                }

                if (has_abstract_method && !modifiers.contains (ValaModifier.ABSTRACT) && kind == Kind.CLASS) {
                    error ("class with abstract methods must be abstract");
                }

                return new TypeSpec (this);
            }

        }
    }

    public enum ValaModifier{
        // Access Modifiers (Start at 1 so PUBLIC is not (gpointer) 0/NULL in Gee collections)
        PUBLIC = 1,
        PRIVATE,
        PROTECTED,
        INTERNAL,

        // Lifecycle & Inheritance
        STATIC,
        ABSTRACT,
        VIRTUAL,
        OVERRIDE,
        SEALED,
        NEW,

        // Concurrency & Async
        ASYNC,
        YIELD,

        // Memory Management
        OWNED,
        UNOWNED,
        WEAK,

        // Other
        CONST,
        DYNAMIC,
        EXTERN,
        INLINE,
        PARTIAL,
        VOLATILE
    }

}
