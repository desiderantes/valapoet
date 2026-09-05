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

public class PropertySpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/property_spec/auto_property", () => {
            var prop = PropertySpec.builder (TypeName.STRING, "title")
            .visibility (Visibility.PUBLIC)
            .add_comment ("Prop comment %s %d", "prop", 1)
            .add_valadoc ("Prop doc %s", "title")
            .auto ()
            .build ();

            var test_class = TypeSpec.class_builder ("Book")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_property (prop)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("// Prop comment prop 1"));
            assert_true (code.contains ("Prop doc title"));
            assert_true (code.contains ("public string title {\n\t\tget; set;\n\t}"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/property_spec/custom_accessors_and_visibility", () => {
            var prop = PropertySpec.builder (TypeName.INT, "counter")
            .visibility (Visibility.PUBLIC)
            .get_body (CodeBlock.builder ().add_statement ("return _counter").build ())
            .set_body (CodeBlock.builder ().add_statement ("_counter = value").build ())
            .private_set ()
            .build ();

            var field = FieldSpec.builder (TypeName.INT, "_counter")
            .visibility (Visibility.PRIVATE)
            .initializer ("0")
            .build ();

            var test_class = TypeSpec.class_builder ("CounterService")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (field)
            .add_property (prop)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("get {\n\t\t\treturn _counter;\n\t\t}"));
            assert_true (code.contains ("private set {\n\t\t\t_counter = value;\n\t\t}"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/property_spec/default_initializer", () => {
            var prop = PropertySpec.builder (TypeName.INT, "max_limit")
            .visibility (Visibility.PUBLIC)
            .auto ()
            .default_value ("100")
            .build ();

            var test_class = TypeSpec.class_builder ("Config")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_property (prop)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("default = 100;"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
