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
using Gee;
using ValaPoetTestUtil;

public class ReadmeSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/readme_hello_world", () => {
            var main_method = MethodSpec.method_builder ("main")
            .add_modifiers (ValaModifier.PUBLIC, ValaModifier.STATIC)
            .returns (TypeName.INT)
            .add_parameter (ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args").build ())
            .add_statement ("stdout.printf (\"Hello, ValaPoet!\\n\")")
            .add_statement ("return 0")
            .build ();

            var hello_world_class = TypeSpec.class_builder ("HelloWorld")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (main_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (TypeSpec.namespace_builder ("Example")
                       .add_type (hello_world_class)
                       .build ()
            )
            .build ();

            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_control_flow", () => {
            var main_method = MethodSpec.method_builder ("main")
            .add_statement ("int total = 0")
            .begin_control_flow ("for (int i = 0; i < 10; i++)")
            .add_statement ("total += i")
            .end_control_flow ()
            .build ();

            var demo_class = TypeSpec.class_builder ("Demo")
            .add_method (main_method)
            .build ();

            var vala_file = ValaFile.builder ().add_type (demo_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_properties", () => {
            var age_prop = PropertySpec.builder (TypeName.INT, "age")
            .add_modifiers (ValaModifier.PUBLIC)
            .auto ()
            .default_value ("32")
            .build ();

            var get_body = CodeBlock.builder ().add_statement ("return _name").build ();
            var set_body = CodeBlock.builder ().add_statement ("_name = value").build ();

            var name_prop = PropertySpec.builder (TypeName.STRING, "name")
            .add_modifiers (ValaModifier.PUBLIC)
            .get_body (get_body)
            .set_body (set_body)
            .build ();

            var name_field = FieldSpec.builder (TypeName.STRING, "_name")
            .add_modifiers (ValaModifier.PRIVATE)
            .build ();

            var person_class = TypeSpec.class_builder ("Person")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (name_field)
            .add_property (age_prop)
            .add_property (name_prop)
            .build ();

            var vala_file = ValaFile.builder ().add_type (person_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_signals", () => {
            var activated_signal = SignalSpec.builder ("activated")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "value").build ())
            .add_attribute (AttributeSpec.builder ("Signal").add_argument ("action", "true").build ())
            .build ();

            var widget_class = TypeSpec.class_builder ("MyWidget")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_signal (activated_signal)
            .build ();

            var vala_file = ValaFile.builder ().add_type (widget_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_constructors", () => {
            var path_field = FieldSpec.builder (TypeName.STRING, "path")
            .add_modifiers (ValaModifier.PUBLIC)
            .build ();

            var from_file_ctor = MethodSpec.named_constructor_builder ("from_file")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_parameter (ParameterSpec.builder (ClassName.get ("GLib", "File"), "file").build ())
            .add_statement ("this.path = file.get_path ()")
            .build ();

            var doc_class = TypeSpec.class_builder ("Document")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (path_field)
            .add_method (from_file_ctor)
            .build ();

            var vala_file = ValaFile.builder ().add_type (doc_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string (), { "gio-2.0" }));
        });

        Test.add_func ("/valapoet/readme_contracts", () => {
            var safe_divide = MethodSpec.method_builder ("safe_divide")
            .add_modifiers (ValaModifier.PUBLIC)
            .returns (TypeName.DOUBLE)
            .add_parameter (ParameterSpec.builder (TypeName.DOUBLE, "numerator").build ())
            .add_parameter (ParameterSpec.builder (TypeName.DOUBLE, "denominator").build ())
            .add_requires ("denominator != 0.0")
            .add_ensures ("result >= 0.0")
            .add_statement ("return numerator / denominator")
            .build ();

            var math_class = TypeSpec.class_builder ("MathUtils")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (safe_divide)
            .build ();

            var vala_file = ValaFile.builder ().add_type (math_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_parameter_directions", () => {
            var process_data = MethodSpec.method_builder ("process_data")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "input").build ())
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "output")
                            .direction (ParameterSpec.Direction.OUT)
                            .build ())
            .add_parameter (ParameterSpec.builder (TypeName.BOOL, "verbose")
                            .default_value ("false")
                            .build ())
            .add_statement ("output = input.to_string ()")
            .build ();

            var processor_class = TypeSpec.class_builder ("DataProcessor")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (process_data)
            .build ();

            var vala_file = ValaFile.builder ().add_type (processor_class).build ();
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/readme_generics_delegates_nameallocator", () => {
            var type_variable = TypeVariableName.get ("T");
            var list_class = TypeSpec.class_builder ("CustomList")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_type_variable (type_variable)
            .build ();

            var cb_delegate = DelegateName.get ("Callback", TypeName.VOID)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "id").build ());

            var allocator = new NameAllocator ();
            assert_cmpstr (allocator.new_name ("class"), GLib.CompareOperator.EQ, "@class");
            assert_cmpstr (allocator.new_name ("int"), GLib.CompareOperator.EQ, "_int");

            var vala_file = ValaFile.builder ()
            .add_type (list_class)
            .add_delegate (cb_delegate)
            .build ();

            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
