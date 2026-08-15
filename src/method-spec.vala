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

    public class MethodSpec : GLib.Object {


        public enum Kind {
            METHOD,
            CONSTRUCTOR,
            NAMED_CONSTRUCTOR,
            DESTRUCTOR
        }

        public Kind kind { get; private set; }
        public string name { get; private set; }
        public CodeBlock valadoc { get; private set; }
        public Gee.ArrayList<AttributeSpec> annotations { get; private set; }
        public Gee.HashSet<ValaModifier> modifiers { get; private set; }
        public Gee.ArrayList<TypeVariableName> type_variables { get; private set; }
        public TypeName ? return_type { get; private set; }
        public Gee.ArrayList<ParameterSpec> parameters { get; private set; }
        public Gee.ArrayList<CodeBlock> requires_contracts { get; private set; }
        public Gee.ArrayList<CodeBlock> ensures_contracts { get; private set; }
        public CodeBlock code { get; private set; }
        public Gee.ArrayList<TypeName> throws_errors { get; private set; }
        public TypeName ? explicit_interface { get; private set; }
        public bool variadic { get; private set; }

        private MethodSpec (Builder builder) {
            this.kind = builder.kind;
            this.name = builder.name;
            this.valadoc = builder.valadoc.build ();
            this.annotations = new Gee.ArrayList<AttributeSpec>();
            this.annotations.add_all (builder.annotations);
            this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash, vala_modifier_equal);
            foreach (var m in builder.modifiers) {
                this.modifiers.add (m);
            }
            this.type_variables = new Gee.ArrayList<TypeVariableName>();
            this.type_variables.add_all (builder.type_variables);
            this.return_type = builder.return_type;
            this.parameters = new Gee.ArrayList<ParameterSpec>();
            this.parameters.add_all (builder.parameters);
            this.requires_contracts = new Gee.ArrayList<CodeBlock>();
            this.requires_contracts.add_all (builder.requires_contracts);
            this.ensures_contracts = new Gee.ArrayList<CodeBlock>();
            this.ensures_contracts.add_all (builder.ensures_contracts);
            this.code = builder.code.build ();
            this.throws_errors = new Gee.ArrayList<TypeName>();
            this.throws_errors.add_all (builder.throws_errs);
            this.explicit_interface = builder.explicit_iface;
            this.variadic = builder.is_variadic;
        }

        public static Builder method_builder (string name) {
            return new Builder (Kind.METHOD, name);
        }

        public static Builder constructor_builder () {
            return new Builder (Kind.CONSTRUCTOR, "new");
        }

        public static Builder named_constructor_builder (string name) {
            return new Builder (Kind.NAMED_CONSTRUCTOR, name);
        }

        public static Builder destructor_builder () {
            return new Builder (Kind.DESTRUCTOR, "~");
        }

        public class Builder : GLib.Object {
            public Kind kind { get; private set; }
            public string name { get; private set; }
            public CodeBlock.Builder valadoc { get; private set; }
            public Gee.ArrayList<AttributeSpec> annotations { get; private set; }
            public Gee.HashSet<ValaModifier> modifiers { get; private set; }
            public Gee.ArrayList<TypeVariableName> type_variables { get; private set; }
            public TypeName ? return_type { get; private set; }
            public Gee.ArrayList<ParameterSpec> parameters { get; private set; }
            public Gee.ArrayList<CodeBlock> requires_contracts { get; private set; }
            public Gee.ArrayList<CodeBlock> ensures_contracts { get; private set; }
            public CodeBlock.Builder code { get; private set; }
            public Gee.ArrayList<TypeName> throws_errs { get; private set; }
            public TypeName ? explicit_iface { get; private set; }
            public bool is_variadic { get; private set; }

            public Builder (Kind kind, string name) {
                this.kind = kind;
                this.name = name;
                this.valadoc = new CodeBlock.Builder ();
                this.annotations = new Gee.ArrayList<AttributeSpec>();
                this.modifiers = new Gee.HashSet<ValaModifier>(vala_modifier_hash, vala_modifier_equal);
                this.type_variables = new Gee.ArrayList<TypeVariableName>();
                this.parameters = new Gee.ArrayList<ParameterSpec>();
                this.requires_contracts = new Gee.ArrayList<CodeBlock>();
                this.ensures_contracts = new Gee.ArrayList<CodeBlock>();
                this.code = new CodeBlock.Builder ();
                this.throws_errs = new Gee.ArrayList<TypeName>();
                this.is_variadic = false;
            }

            public Builder add_modifiers (params ValaModifier[] modifiers) {
                foreach (var m in modifiers) {
                    this.modifiers.add (m);
                }
                return this;
            }

            public Builder add_type_variable (TypeVariableName tv) {
                this.type_variables.add (tv);
                return this;
            }

            public Builder add_attribute (AttributeSpec attribute) {
                this.annotations.add (attribute);
                return this;
            }

            public Builder add_valadoc (string format, ...) {
                var va = va_list ();
                this.valadoc.add_valist (format, va);
                return this;
            }

            public Builder returns (TypeName return_type) {
                this.return_type = return_type;
                return this;
            }

            public Builder add_parameter (ParameterSpec parameter) {
                this.parameters.add (parameter);
                return this;
            }

            public Builder add_requires (string format, ...) {
                var va = va_list ();
                this.requires_contracts.add (CodeBlock.of_valist (format, va));
                return this;
            }

            public Builder add_ensures (string format, ...) {
                var va = va_list ();
                this.ensures_contracts.add (CodeBlock.of_valist (format, va));
                return this;
            }

            public Builder add_statement (string format, ...) {
                var va = va_list ();
                this.code.add_statement_valist (format, va);
                return this;
            }

            public Builder add_statement_raw (string code) {
                this.code.add_statement_raw (code);
                return this;
            }

            public Builder add_raw (string code) {
                this.code.add_raw (code);
                return this;
            }

            public Builder begin_control_flow (string format, ...) {
                var va = va_list ();
                this.code.begin_control_flow_valist (format, va);
                return this;
            }

            public Builder next_control_flow (string format, ...) {
                var va = va_list ();
                this.code.next_control_flow_valist (format, va);
                return this;
            }

            public Builder end_control_flow () {
                this.code.end_control_flow ();
                return this;
            }

            public Builder add_code (CodeBlock code_block) {
                this.code.add_code (code_block);
                return this;
            }

            public Builder indent () {
                this.code.indent ();
                return this;
            }

            public Builder unindent () {
                this.code.unindent ();
                return this;
            }

            public Builder set_variadic (bool variadic = true) {
                this.is_variadic = variadic;
                return this;
            }

            public Builder add_throws (TypeName error_domain) {
                this.throws_errs.add (error_domain);
                return this;
            }

            public Builder explicit_interface (TypeName interface_type) {
                this.explicit_iface = interface_type;
                return this;
            }

            public MethodSpec build () {
                if (modifiers.contains (ValaModifier.ABSTRACT) && !code.is_empty ()) {
                    error ("abstract method cannot have code");
                }

                for (var i = 0; i < parameters.size; i++) {
                    if (parameters.get (i).is_params && i != parameters.size - 1) {
                        error ("The 'params' modifier can only be applied to the last parameter of a method.");
                    }
                }
                return new MethodSpec (this);
            }

        }
    }

}
