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

    public class ClassName : TypeName {

        public string namespace_name { get; private set; }
        public string simple_name { get; private set; }
        public ClassName ? enclosing_class_name { get; private set; }

        public ClassName (string namespace_name, string simple_name, ClassName ? enclosing_class_name = null) {
            this.namespace_name = namespace_name;
            this.simple_name = simple_name;
            this.enclosing_class_name = enclosing_class_name;
            this.attributes = new GLib.List<AttributeSpec>();
        }

        public static new ClassName get (string namespace_name, string simple_name) {
            return new ClassName (namespace_name, simple_name);
        }

        public ClassName nested_class (string name) {
            return new ClassName (this.namespace_name, name, this);
        }

        public string canonical_name {
            owned get {
                if (enclosing_class_name != null) {
                    return enclosing_class_name.canonical_name + "." + simple_name;
                }
                if (namespace_name != "") {
                    return namespace_name + "." + simple_name;
                }
                return simple_name;
            }
        }

        public override string to_string () {
            return this.canonical_name;
        }

        public override TypeName copy () {
            var copy = new ClassName (this.namespace_name, this.simple_name, this.enclosing_class_name);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.attributes) {
                copy.attributes.append (a);
            }
            return copy;
        }

    }

}
