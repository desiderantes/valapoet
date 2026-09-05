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

public class EnumSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/enum_spec/constants_and_methods", () => {
            var enum_spec = EnumSpec.builder ("Status")
            .visibility (Visibility.PUBLIC)
            .add_comment ("Enum comment %s %d", "status", 1)
            .add_valadoc ("Enum doc %s", "Status")
            .add_constant ("IDLE")
            .add_constant ("RUNNING")
            .add_constant ("FINISHED")
            .add_method (
                MethodSpec.method_builder ("to_display_string")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.STRING)
                .begin_switch ("this")
                .add_statement ("case IDLE: return \"Idle\"")
                .add_statement ("case RUNNING: return \"Running\"")
                .add_statement ("case FINISHED: return \"Finished\"")
                .add_statement ("default: return \"Unknown\"")
                .end_control_flow ()
                .build ()
            )
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (enum_spec)
            .build ();

            string code = vala_file.to_string ();
            GLib.stdout.printf ("\n=== TEST 1: ENUM WITH METHOD ===\n%s\n", code);
            assert_true (code.contains ("// Enum comment status 1"));
            assert_true (code.contains ("Enum doc Status"));
            assert_true (code.contains ("public enum Status {\n"));
            assert_true (code.contains ("IDLE,\n"));
            assert_true (code.contains ("\tpublic string to_display_string () {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/enum_spec/nested_enum_methods", () => {
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
            GLib.stdout.printf ("\n=== TEST 2: NESTED ENUM WITH METHOD ===\n%s\n", code);
            assert_true (code.contains ("\tpublic enum Level {\n"));
            assert_true (code.contains ("\t\tLOW,\n"));
            assert_true (code.contains ("\t\tHIGH;\n"));
            assert_true (code.contains ("\t\tpublic bool is_high () {\n"));
            assert_true (code.contains ("\t\t\treturn this == HIGH;\n"));
            assert_true (code.contains ("\t\t}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/enum_spec/namespace_enum_methods", () => {
            var enum_spec = EnumSpec.builder ("State")
            .visibility (Visibility.PUBLIC)
            .add_constant ("OFF")
            .add_constant ("ON")
            .add_method (
                MethodSpec.method_builder ("is_on")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.BOOL)
                .add_statement ("return this == ON")
                .build ()
            )
            .build ();

            var ns = TypeSpec.namespace_builder ("Org.Example")
            .add_type (enum_spec)
            .build ();

            var vala_file = ValaFile.builder ()
            .set_namespace (ns)
            .build ();

            string code = vala_file.to_string ();
            GLib.stdout.printf ("\n=== TEST 3: NAMESPACE ENUM WITH METHOD ===\n%s\n", code);
            assert_true (code.contains ("namespace Org.Example {\n"));
            assert_true (code.contains ("\tpublic enum State {\n"));
            assert_true (code.contains ("\t\tOFF,\n"));
            assert_true (code.contains ("\t\tON;\n"));
            assert_true (code.contains ("\t\tpublic bool is_on () {\n"));
            assert_true (code.contains ("\t\t\treturn this == ON;\n"));
            assert_true (code.contains ("\t\t}\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
