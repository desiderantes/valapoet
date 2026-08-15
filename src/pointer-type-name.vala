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

    /// Models a pointer to another type, such as `int*`.
    public class PointerTypeName : TypeName {

        public TypeName pointed_to_type { get; private set; }

        public PointerTypeName (TypeName pointed_to_type) {
            this.pointed_to_type = pointed_to_type;
            this.annotations = new Gee.ArrayList<AttributeSpec>();
        }

        public override string to_string () {
            return pointed_to_type.to_string () + "*";
        }

        public override TypeName copy () {
            var copy = new PointerTypeName (this.pointed_to_type.copy ());
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.annotations) {
                copy.annotations.add (a);
            }
            return copy;
        }

    }

}
