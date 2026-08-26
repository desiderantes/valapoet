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

public class IndentationTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/indentation/enum_methods", () => {
            var enum_spec = EnumSpec.builder ("Status")
            .visibility (Visibility.PUBLIC)
            .add_constant ("IDLE")
            .add_constant ("RUNNING")
            .add_method (
                MethodSpec.method_builder ("is_running")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.BOOL)
                .add_statement ("return this == RUNNING")
                .build ()
            )
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (enum_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public enum Status {\n\tIDLE,\n\tRUNNING;\n\n\tpublic bool is_running () {\n\t\treturn this == RUNNING;\n\t}\n}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/indentation/nested_enum_methods", () => {
            var enum_spec = EnumSpec.builder ("Level")
            .visibility (Visibility.PUBLIC)
            .add_constant ("LOW")
            .add_constant ("HIGH")
            .add_method (
                MethodSpec.method_builder ("is_high")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.BOOL)
                .add_statement ("return this == HIGH")
                .build ()
            )
            .build ();

            var outer_class = TypeSpec.class_builder ("Config")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_type (enum_spec)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (outer_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("\tpublic enum Level {\n\t\tLOW,\n\t\tHIGH;\n\n\t\tpublic bool is_high () {\n\t\t\treturn this == HIGH;\n\t\t}\n\t}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/indentation/nested_control_flow", () => {
            var method = MethodSpec.method_builder ("process")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "items").build ())
            .begin_foreach ("var item in items")
                .begin_if ("item != null")
                    .add_statement ("print (item)")
                .else_block ()
                    .add_statement ("warning (\"null item\")")
                .end_control_flow ()
            .end_control_flow ()
            .build ();

            var test_class = TypeSpec.class_builder ("Processor")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("\tpublic void process (string[] items) {\n\t\tforeach (var item in items) {\n\t\t\tif (item != null) {\n\t\t\t\tprint (item);\n\t\t\t} else {\n\t\t\t\twarning (\"null item\");\n\t\t\t}\n\t\t}\n\t}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/indentation/custom_space_indentation", () => {
            var enum_spec = EnumSpec.builder ("Status")
            .visibility (Visibility.PUBLIC)
            .add_constant ("IDLE")
            .add_constant ("RUNNING")
            .add_method (
                MethodSpec.method_builder ("is_running")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.BOOL)
                .add_statement ("return this == RUNNING")
                .build ()
            )
            .build ();

            var vala_file = ValaFile.builder ()
            .indent ("    ")
            .add_type (enum_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public enum Status {\n    IDLE,\n    RUNNING;\n\n    public bool is_running () {\n        return this == RUNNING;\n    }\n}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
