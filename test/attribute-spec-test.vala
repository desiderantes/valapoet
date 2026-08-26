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

using ValaPoet;
using ValaPoetTestUtil;

public class AttributeSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/attributes/ccode", () => {
            var ccode_attr = AttributeSpec.ccode ()
            .cname ("my_custom_c_func")
            .cheader_filename ("my_header.h")
            .array_length (false)
            .array_length_type ("uint32")
            .has_type_id (true)
            .type_id ("MY_TYPE_ID")
            .notify (false)
            .build ();

            var dummy_method = MethodSpec.method_builder ("foo")
            .add_attribute (ccode_attr)
            .visibility (Visibility.PUBLIC)
            .build ();

            var dummy_class = TypeSpec.class_builder ("DummyClass")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (dummy_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (dummy_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("array_length = false"));
            assert_true (code.contains ("array_length_type = \"uint32\""));
            assert_true (code.contains ("cheader_filename = \"my_header.h\""));
            assert_true (code.contains ("cname = \"my_custom_c_func\""));
            assert_true (code.contains ("has_type_id = true"));
            assert_true (code.contains ("notify = false"));
            assert_true (code.contains ("type_id = \"MY_TYPE_ID\""));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/attributes/dbus", () => {
            var dbus_attr = AttributeSpec.dbus ()
            .name ("org.example.TestInterface")
            .timeout (3000)
            .no_reply (true)
            .build ();

            var dummy_class = TypeSpec.class_builder ("TestService")
            .add_attribute (dbus_attr)
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (dummy_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("[DBus (name = \"org.example.TestInterface\", no_reply = true, timeout = 3000)]\n"));
            assert_true (CodeCompiler.verify_code_compiles (code, { "gio-2.0" }));
        });

        Test.add_func ("/valapoet/attributes/gtk_and_modifiers", () => {
            var gtk_child = AttributeSpec.gtk_child ();
            var gtk_cb = AttributeSpec.gtk_callback ();
            var gtk_tmpl = AttributeSpec.gtk_template ("/org/example/ui.xml");
            var compact = AttributeSpec.compact ();
            var simple = AttributeSpec.simple_type ();
            var immutable = AttributeSpec.immutable ();
            var single_inst = AttributeSpec.single_instance ();
            var mod_init = AttributeSpec.module_init ();

            var button_field = FieldSpec.builder (TypeName.OBJECT.@unowned (), "button")
            .add_attribute (gtk_child)
            .visibility (Visibility.PRIVATE)
            .build ();

            var cb_method = MethodSpec.method_builder ("on_clicked")
            .add_attribute (gtk_cb)
            .visibility (Visibility.PRIVATE)
            .build ();

            var widget_class = TypeSpec.class_builder ("MyWidget")
            .add_attribute (gtk_tmpl)
            .add_attribute (single_inst)
            .add_attribute (mod_init)
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (button_field)
            .add_method (cb_method)
            .build ();

            var compact_class = TypeSpec.class_builder ("CompactNode")
            .add_attribute (compact)
            .visibility (Visibility.PUBLIC)
            .build ();

            var struct_spec = TypeSpec.struct_builder ("Point")
            .add_attribute (simple)
            .add_attribute (immutable)
            .visibility (Visibility.PUBLIC)
            .add_field (FieldSpec.builder (TypeName.INT, "x").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.INT, "y").visibility (Visibility.PUBLIC).build ())
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (widget_class)
            .add_type (compact_class)
            .add_type (struct_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("[GtkChild]\n"));
            assert_true (code.contains ("[GtkCallback]\n"));
            assert_true (code.contains ("[GtkTemplate (ui = \"/org/example/ui.xml\")]\n"));
            assert_true (code.contains ("[Compact]\n"));
            assert_true (code.contains ("[SingleInstance]\n"));
            assert_true (code.contains ("[ModuleInit]\n"));
            assert_true (code.contains ("[SimpleType]\n"));
            assert_true (code.contains ("[Immutable]\n"));
            assert_true (code.contains ("unowned GLib.Object button;"));
        });

        Test.add_func ("/valapoet/attributes/compilable_modifiers", () => {
            var compact = AttributeSpec.compact ();
            var simple = AttributeSpec.simple_type ();
            var immutable = AttributeSpec.immutable ();
            var single_inst = AttributeSpec.single_instance ();
            var mod_init = AttributeSpec.module_init ();

            var service_class = TypeSpec.class_builder ("AppService")
            .add_attribute (single_inst)
            .add_attribute (mod_init)
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .build ();

            var compact_class = TypeSpec.class_builder ("NativeNode")
            .add_attribute (compact)
            .visibility (Visibility.PUBLIC)
            .build ();

            var struct_spec = TypeSpec.struct_builder ("Vec2")
            .add_attribute (simple)
            .add_attribute (immutable)
            .visibility (Visibility.PUBLIC)
            .add_field (FieldSpec.builder (TypeName.INT, "x").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.INT, "y").visibility (Visibility.PUBLIC).build ())
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (service_class)
            .add_type (compact_class)
            .add_type (struct_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
