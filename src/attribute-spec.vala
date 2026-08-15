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

    public class AttributeSpec : GLib.Object {

        public string name { get; private set; }
        public Gee.HashMap<string, CodeBlock> arguments { get; private set; }

        private AttributeSpec (Builder builder) {
            this.name = builder.name;
            this.arguments = new Gee.HashMap<string, CodeBlock>();
            foreach (var entry in builder.arguments.entries) {
                this.arguments[entry.key] = entry.value;
            }
        }

        public static Builder builder (string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public Gee.HashMap<string, CodeBlock> arguments { get; private set; }

            public Builder (string name) {
                this.name = name;
                this.arguments = new Gee.HashMap<string, CodeBlock>();
            }

            public Builder add_argument (string name, string format, ...) {
                var va = va_list ();
                arguments[name] = CodeBlock.of_valist (format, va);
                return this;
            }

            public AttributeSpec build () {
                return new AttributeSpec (this);
            }

        }
    }

}
