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

    public class DelegateName : TypeName, Nameable {

        public string name { get; protected set; }
        public TypeName return_type { get; private set; }
        public unowned GLib.List<ParameterSpec> parameters { get; private set; }
        public Visibility visibility { get; private set; }
        public unowned GLib.List<SymbolModifier> modifiers { get; private set; }

        public DelegateName (string name, TypeName return_type, GLib.List<ParameterSpec> ? parameters = null) {
            this.name = name;
            this.return_type = return_type;
            this.parameters = new GLib.List<ParameterSpec>();
            if (parameters != null) {
                foreach (var p in parameters) {
                    this.parameters.append (p);
                }
            }
            this.attributes = new GLib.List<AttributeSpec>();
            this.visibility = Visibility.NONE;
            this.modifiers = new GLib.List<SymbolModifier>();
        }

        public static new DelegateName get (string name, TypeName return_type) {
            return new DelegateName (name, return_type);
        }

        public DelegateName add_modifiers (params SymbolModifier[] modifiers) {
            foreach (var m in modifiers) {
                if (!m.targets_delegate ()) {
                    warning ("Modifier '%s' is not applicable to delegates.", m.to_string ());
                }
                if (this.modifiers.find (m) == null) {
                    this.modifiers.append (m);
                }
            }
            return this;
        }

        public DelegateName with_visibility (Visibility vis) {
            this.visibility = vis;
            return this;
        }

        public DelegateName add_parameter (ParameterSpec param) {
            this.parameters.append (param);
            return this;
        }

        public DelegateName add_attribute (AttributeSpec attr) {
            this.attributes.append (attr);
            return this;
        }

        public override string to_string () {
            return this.name;
        }

        public override TypeName copy () {
            var copy_params = new GLib.List<ParameterSpec>();
            foreach (var p in this.parameters) {
                copy_params.append (p);
            }
            var copy = new DelegateName (this.name, this.return_type.copy (), copy_params);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            copy.is_unowned = this.is_unowned;
            copy.is_owned = this.is_owned;
            copy.visibility = this.visibility;
            foreach (var m in this.modifiers) {
                copy.modifiers.append (m);
            }
            foreach (var a in this.attributes) {
                copy.attributes.append (a);
            }
            return copy;
        }

    }

    public class DelegateSpec : GLib.Object {

        public static DelegateName builder (string name, TypeName return_type) {
            return DelegateName.get (name, return_type);
        }

    }

}
