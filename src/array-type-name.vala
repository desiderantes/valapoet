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

    public class ArrayTypeName : TypeName {

        public TypeName component_type { get; private set; }
        public int rank { get; private set; }

        public ArrayTypeName (TypeName component_type, int rank = 1) {
            this.component_type = component_type;
            this.rank = rank;
            this.annotations = new Gee.ArrayList<AttributeSpec>();
        }

        public ArrayTypeName.of (TypeName component_type, int rank = 1) {
            this(component_type, rank);
        }

        public override string to_string() {
            var commas = new string[rank];
            for (int i = 0 ; i < rank ; i++) {
                commas[i] = "";
            }
            string rank_str = string.joinv (",", commas);
            return component_type.to_string () + "[" + rank_str + "]";
        }

        public override TypeName copy() {
            var copy = new ArrayTypeName (this.component_type.copy (), this.rank);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            foreach (var a in this.annotations) {
                copy.annotations.add (a);
            }
            return copy;
        }

    }

}
