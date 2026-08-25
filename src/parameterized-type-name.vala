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

    public class ParameterizedTypeName : TypeName {

        public TypeName raw_type { get; private set; }
        public unowned GLib.List<TypeName> type_arguments { get; private set; }

        public ParameterizedTypeName (TypeName raw_type, GLib.List<TypeName> type_arguments) {
            this.raw_type = raw_type;
            this.type_arguments = new GLib.List<TypeName>();
            foreach (var arg in type_arguments) {
                this.type_arguments.append (arg);
            }
            this.attributes = new GLib.List<AttributeSpec>();
        }

        public ParameterizedTypeName.of (TypeName raw_type, params TypeName[] type_arguments) {
            var list = new GLib.List<TypeName>();
            foreach (var arg in type_arguments) {
                list.append (arg);
            }
            this (raw_type, list);
        }

        public override string to_string () {
            string[] args_str = {};
            foreach (var arg in type_arguments) {
                args_str += arg.to_string ();
            }
            return raw_type.to_string () + "<" + string.joinv (", ", args_str) + ">";
        }

        public override TypeName copy () {
            var new_args = new GLib.List<TypeName>();
            foreach (var arg in this.type_arguments) {
                new_args.append (arg.copy ());
            }
            var copy = new ParameterizedTypeName (this.raw_type.copy (), new_args);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.attributes) {
                copy.attributes.append (a);
            }
            return copy;
        }

    }

}
