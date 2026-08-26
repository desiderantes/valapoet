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
        public string? comment { get; private set; }
        public CodeBlock? valadoc { get; private set; }
        public unowned GLib.List<AttributeSpec> attributes { get; private set; }
        public unowned GLib.List<TypeVariableName> type_variables { get; private set; }
        public TypeName ? return_type { get; private set; }
        public unowned GLib.List<ParameterSpec> parameters { get; private set; }
        public unowned GLib.List<CodeBlock> requires_contracts { get; private set; }
        public unowned GLib.List<CodeBlock> ensures_contracts { get; private set; }
        public CodeBlock code { get; private set; }
        public unowned GLib.List<TypeName> throws_errors { get; private set; }
        public TypeName ? explicit_interface { get; private set; }
        public Visibility visibility { get; private set; }
        public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
        public bool variadic { get; private set; }

        private MethodSpec (Builder builder) {
            this.kind = builder.kind;
            this.name = builder.name;
            this.visibility = builder.vis;
            this.comment = builder.comment;
            this.valadoc = builder.valadoc.build ();
            this.attributes = new GLib.List<AttributeSpec>();
            foreach (var a in builder.attributes) {
                this.attributes.append (a);
            }
            this.modifiers = new GLib.List<SymbolModifier>();
            foreach (var m in builder.modifiers) {
                this.modifiers.append (m);
            }
            this.type_variables = new GLib.List<TypeVariableName>();
            foreach (var tv in builder.type_variables) {
                this.type_variables.append (tv);
            }
            this.return_type = builder.return_type;
            this.parameters = new GLib.List<ParameterSpec>();
            foreach (var p in builder.parameters) {
                this.parameters.append (p);
            }
            this.requires_contracts = new GLib.List<CodeBlock>();
            foreach (var rc in builder.requires_contracts) {
                this.requires_contracts.append (rc);
            }
            this.ensures_contracts = new GLib.List<CodeBlock>();
            foreach (var ec in builder.ensures_contracts) {
                this.ensures_contracts.append (ec);
            }
            this.code = builder.code.build ();
            this.throws_errors = new GLib.List<TypeName>();
            foreach (var te in builder.throws_errs) {
                this.throws_errors.append (te);
            }
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
            public string? comment { get; private set; }
            public CodeBlock.Builder valadoc { get; private set; }
            public unowned GLib.List<AttributeSpec> attributes { get; private set; }
            public Visibility vis { get; private set; }
            public unowned GLib.List<SymbolModifier> modifiers { get; private set; }
            public unowned GLib.List<TypeVariableName> type_variables { get; private set; }
            public TypeName ? return_type { get; private set; }
            public unowned GLib.List<ParameterSpec> parameters { get; private set; }
            public unowned GLib.List<CodeBlock> requires_contracts { get; private set; }
            public unowned GLib.List<CodeBlock> ensures_contracts { get; private set; }
            public CodeBlock.Builder code { get; private set; }
            public unowned GLib.List<TypeName> throws_errs { get; private set; }
            public TypeName ? explicit_iface { get; private set; }
            public bool is_variadic { get; private set; }

            public Builder (Kind kind, string name) {
                this.kind = kind;
                this.name = name;
                this.vis = Visibility.NONE;
                this.valadoc = new CodeBlock.Builder ();
                this.attributes = new GLib.List<AttributeSpec>();
                this.modifiers = new GLib.List<SymbolModifier>();
                this.type_variables = new GLib.List<TypeVariableName>();
                this.parameters = new GLib.List<ParameterSpec>();
                this.requires_contracts = new GLib.List<CodeBlock>();
                this.ensures_contracts = new GLib.List<CodeBlock>();
                this.code = new CodeBlock.Builder ();
                this.throws_errs = new GLib.List<TypeName>();
                this.is_variadic = false;
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

            public Builder add_type_variable (TypeVariableName tv) {
                this.type_variables.append (tv);
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

            public Builder add_valadoc_spec (ValadocSpec doc) {
                this.valadoc.add_code (doc.to_code_block ());
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

            public Builder add_requires (string format, ...) {
                var va = va_list ();
                this.requires_contracts.append (CodeBlock.of_valist (format, va));
                return this;
            }

            public Builder add_ensures (string format, ...) {
                var va = va_list ();
                this.ensures_contracts.append (CodeBlock.of_valist (format, va));
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

            public Builder begin_foreach (string format, ...) {
                var va = va_list ();
                this.code.begin_control_flow_valist ("foreach (" + format + ")", va);
                return this;
            }

            public Builder begin_while (string format, ...) {
                var va = va_list ();
                this.code.begin_control_flow_valist ("while (" + format + ")", va);
                return this;
            }

            public Builder begin_if (string format, ...) {
                var va = va_list ();
                this.code.begin_control_flow_valist ("if (" + format + ")", va);
                return this;
            }

            public Builder else_if (string format, ...) {
                var va = va_list ();
                this.code.next_control_flow_valist ("else if (" + format + ")", va);
                return this;
            }

            public Builder else_block () {
                this.code.else_block ();
                return this;
            }

            public Builder begin_switch (string format, ...) {
                var va = va_list ();
                this.code.begin_control_flow_valist ("switch (" + format + ")", va);
                return this;
            }

            public Builder begin_try () {
                this.code.begin_try ();
                return this;
            }

            public Builder begin_catch (string format, ...) {
                var va = va_list ();
                this.code.begin_catch (format, va);
                return this;
            }

            public Builder begin_finally () {
                this.code.begin_finally ();
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
                this.throws_errs.append (error_domain);
                return this;
            }

            public Builder explicit_interface (TypeName interface_type) {
                this.explicit_iface = interface_type;
                return this;
            }

            public MethodSpec build () {
                if (kind == Kind.DESTRUCTOR) {
                    if (parameters != null && parameters.length () > 0) {
                        error ("Destructor cannot have parameters.");
                    }
                    if (vis != Visibility.NONE) {
                        error ("Destructor cannot have visibility qualifiers.");
                    }
                    if (modifiers != null && modifiers.length () > 0) {
                        error ("Destructor cannot have modifiers.");
                    }
                    if (return_type != null) {
                        error ("Destructor cannot specify a return type.");
                    }
                }

                foreach (var m in modifiers) {
                    if (!m.targets_method ()) {
                        warning ("Modifier '%s' is not applicable to methods.", m.to_string ());
                    }
                }

                if (modifiers.find (SymbolModifier.ABSTRACT) != null && !code.is_empty ()) {
                    error ("abstract method cannot have code");
                }

                bool has_params_parameter = false;
                uint param_len = parameters.length ();
                uint i = 0;
                foreach (var param in parameters) {
                    if (param.is_params) {
                        has_params_parameter = true;
                        if (i != param_len - 1) {
                            error ("The 'params' modifier can only be applied to the last parameter of a method.");
                        }
                    }
                    i++;
                }

                if (is_variadic && has_params_parameter) {
                    error ("A method cannot have both C-style varargs (...) and typesafe varargs ('params' modifier).");
                }
                return new MethodSpec (this);
            }

        }
    }

}
