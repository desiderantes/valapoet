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
        public GLib.HashTable<string, CodeBlock> arguments { get; private set; }

        private AttributeSpec (Builder builder) {
            this.name = builder.name;
            this.arguments = new GLib.HashTable<string, CodeBlock> (str_hash, str_equal);
            builder.arguments.foreach ((k, v) => {
                this.arguments.insert (k, v);
            });
        }

        public static Builder builder (string name) {
            return new Builder (name);
        }

        public class Builder : GLib.Object {
            public string name { get; private set; }
            public GLib.HashTable<string, CodeBlock> arguments { get; private set; }

            public Builder (string name) {
                this.name = name;
                this.arguments = new GLib.HashTable<string, CodeBlock> (str_hash, str_equal);
            }

            public Builder add_argument (string name, string format, ...) {
                var va = va_list ();
                arguments.insert (name, CodeBlock.of_valist (format, va));
                return this;
            }

            public AttributeSpec build () {
                return new AttributeSpec (this);
            }

        }
    }

}
