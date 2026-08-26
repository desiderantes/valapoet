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

public class MethodSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/method_spec/builder_and_parameters", () => {
            var get_method = MethodSpec.method_builder ("get")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "index").build ())
            .returns (TypeName.STRING)
            .add_statement ("return \"item\"")
            .build ();

            var set_method = MethodSpec.method_builder ("set")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "index").build ())
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "item").build ())
            .build ();

            var contains_method = MethodSpec.method_builder ("contains")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "needle").build ())
            .returns (TypeName.BOOL)
            .add_statement ("return true")
            .build ();

            var coll_class = TypeSpec.class_builder ("CustomCollection")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (get_method)
            .add_method (set_method)
            .add_method (contains_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (coll_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public string get (int index) {\n"));
            assert_true (code.contains ("public void set (int index, string item) {\n"));
            assert_true (code.contains ("public bool contains (string needle) {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/method_spec/control_flow_delegation", () => {
            var run_method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "items").build ())
            .begin_foreach ("var item in items")
                .begin_if ("item == \"skip\"")
                    .add_statement ("continue")
                .else_if ("item == \"stop\"")
                    .add_statement ("break")
                .else_block ()
                    .add_statement ("stdout.printf (\"Item: %s\\n\", item)")
                .end_control_flow ()
            .end_control_flow ()
            .build ();

            var flow_class = TypeSpec.class_builder ("FlowHelper")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (run_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (flow_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("foreach (var item in items) {\n"));
            assert_true (code.contains ("if (item == \"skip\") {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
