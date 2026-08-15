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

    public class ParameterizedTypeName : TypeName {

        public TypeName raw_type { get; private set; }
        public Gee.ArrayList<TypeName> type_arguments { get; private set; }

        public ParameterizedTypeName (TypeName raw_type,Gee.ArrayList<TypeName> type_arguments) {
            this.raw_type = raw_type;
            this.type_arguments = new Gee.ArrayList<TypeName>();
            this.type_arguments.add_all (type_arguments);
            this.annotations = new Gee.ArrayList<AttributeSpec>();
        }

        public ParameterizedTypeName.of (TypeName raw_type,params TypeName[] type_arguments) {
            var list = new Gee.ArrayList<TypeName>();
            foreach (var arg in type_arguments) {
                list.add (arg);
            }
            this(raw_type,list);
        }

        public override string to_string() {
            var args_str = new Gee.ArrayList<string>();
            foreach (var arg in type_arguments) {
                args_str.add (arg.to_string ());
            }
            return raw_type.to_string () + "<" + string.joinv (", ",args_str.to_array ()) + ">";
        }

        public override TypeName copy() {
            var new_args = new Gee.ArrayList<TypeName>();
            foreach (var arg in this.type_arguments) {
                new_args.add (arg.copy ());
            }
            var copy = new ParameterizedTypeName (this.raw_type.copy (),new_args);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.annotations) {
                copy.annotations.add (a);
            }
            return copy;
        }

    }

}
