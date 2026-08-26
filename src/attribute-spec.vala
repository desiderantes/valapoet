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

        public static CCodeBuilder ccode () {
            return new CCodeBuilder ();
        }

        public static DBusBuilder dbus () {
            return new DBusBuilder ();
        }

        public static AttributeSpec gtk_child () {
            return AttributeSpec.builder ("GtkChild").build ();
        }

        public static AttributeSpec gtk_callback () {
            return AttributeSpec.builder ("GtkCallback").build ();
        }

        public static AttributeSpec gtk_template (string ui_resource_path) {
            return AttributeSpec.builder ("GtkTemplate")
                .add_argument ("ui", "$S", ui_resource_path)
                .build ();
        }

        public static AttributeSpec compact () {
            return AttributeSpec.builder ("Compact").build ();
        }

        public static AttributeSpec simple_type () {
            return AttributeSpec.builder ("SimpleType").build ();
        }

        public static AttributeSpec immutable () {
            return AttributeSpec.builder ("Immutable").build ();
        }

        public static AttributeSpec single_instance () {
            return AttributeSpec.builder ("SingleInstance").build ();
        }

        public static AttributeSpec module_init () {
            return AttributeSpec.builder ("ModuleInit").build ();
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

    public class CCodeBuilder : GLib.Object {
        private AttributeSpec.Builder inner_builder;

        public CCodeBuilder () {
            this.inner_builder = AttributeSpec.builder ("CCode");
        }

        public CCodeBuilder cname (string name) {
            inner_builder.add_argument ("cname", "$S", name);
            return this;
        }

        public CCodeBuilder cheader_filename (string header) {
            inner_builder.add_argument ("cheader_filename", "$S", header);
            return this;
        }

        public CCodeBuilder array_length (bool value) {
            inner_builder.add_argument ("array_length", value ? "true" : "false");
            return this;
        }

        public CCodeBuilder array_length_type (string type) {
            inner_builder.add_argument ("array_length_type", "$S", type);
            return this;
        }

        public CCodeBuilder has_type_id (bool value) {
            inner_builder.add_argument ("has_type_id", value ? "true" : "false");
            return this;
        }

        public CCodeBuilder type_id (string type_id) {
            inner_builder.add_argument ("type_id", "$S", type_id);
            return this;
        }

        public new CCodeBuilder notify (bool value) {
            inner_builder.add_argument ("notify", value ? "true" : "false");
            return this;
        }

        public AttributeSpec build () {
            return inner_builder.build ();
        }
    }

    public class DBusBuilder : GLib.Object {
        private AttributeSpec.Builder inner_builder;

        public DBusBuilder () {
            this.inner_builder = AttributeSpec.builder ("DBus");
        }

        public DBusBuilder name (string name) {
            inner_builder.add_argument ("name", "$S", name);
            return this;
        }

        public DBusBuilder timeout (int msec) {
            inner_builder.add_argument ("timeout", msec.to_string ());
            return this;
        }

        public DBusBuilder no_reply (bool value = true) {
            inner_builder.add_argument ("no_reply", value ? "true" : "false");
            return this;
        }

        public AttributeSpec build () {
            return inner_builder.build ();
        }
    }

}
