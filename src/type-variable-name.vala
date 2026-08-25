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

    public class TypeVariableName : TypeName {

        public string name { get; private set; }
        public TypeName? bounds { get; private set; }

        public TypeVariableName (string name, TypeName? bounds = null) {
            this.name = name;
            this.bounds = bounds;
            this.attributes = new GLib.List<AttributeSpec>();
        }

        public static new TypeVariableName get (string name, TypeName? bounds = null) {
            return new TypeVariableName (name, bounds);
        }

        public override string to_string () {
            if (bounds != null) {
                return name + " : " + bounds.to_string ();
            }
            return name;
        }

        public override TypeName copy () {
            var copy = new TypeVariableName (this.name, (this.bounds != null) ? this.bounds.copy () : null);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.attributes) {
                copy.attributes.append (a);
            }
            return copy;
        }

    }

}
