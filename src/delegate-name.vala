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

using Gee;

namespace ValaPoet {

    public class DelegateName : TypeName {

        public string name { get; private set; }
        public TypeName return_type { get; private set; }
        public Gee.ArrayList<ParameterSpec> parameters { get; private set; }

        public DelegateName (string name, TypeName return_type, Gee.ArrayList<ParameterSpec> ? parameters = null) {
            this.name = name;
            this.return_type = return_type;
            this.parameters = (parameters != null) ? parameters : new Gee.ArrayList<ParameterSpec>();
            this.annotations = new Gee.ArrayList<AttributeSpec>();
        }

        public static new DelegateName get (string name, TypeName return_type) {
            return new DelegateName (name, return_type);
        }

        public DelegateName add_parameter (ParameterSpec param) {
            this.parameters.add (param);
            return this;
        }

        public DelegateName add_annotation (AttributeSpec attr) {
            this.annotations.add (attr);
            return this;
        }

        public override string to_string () {
            return this.name;
        }

        public override TypeName copy () {
            var copy_params = new Gee.ArrayList<ParameterSpec>();
            copy_params.add_all (this.parameters);
            var copy = new DelegateName (this.name, this.return_type.copy (), copy_params);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            copy.is_unowned = this.is_unowned;
            copy.is_owned = this.is_owned;
            foreach (var a in this.annotations) {
                copy.annotations.add (a);
            }
            return copy;
        }

    }

}
