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

public class CodeBlockTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/code_block/placeholders", () => {
            var block = CodeBlock.builder ()
            .add ("$T x = new $T ($S);\n", TypeName.STRING, TypeName.STRING, "hello world")
            .build ();

            var method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_code (block)
            .build ();

            var test_class = TypeSpec.class_builder ("Test")
            .visibility (Visibility.PUBLIC)
            .add_method (method)
            .build ();

            string result = ValaFile.builder ().add_type (test_class).build ().to_string ();
            assert_true (result.contains ("string x = new string (\"hello world\");"));
        });

        Test.add_func ("/valapoet/code_block/control_flow_helpers", () => {
            var block = CodeBlock.builder ()
            .begin_if ("x > 0")
            .add_statement ("print_positive ()")
            .else_if ("x < 0")
            .add_statement ("print_negative ()")
            .else_block ()
            .add_statement ("print_zero ()")
            .end_control_flow ()
            .build ();

            var method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_code (block)
            .build ();

            var test_class = TypeSpec.class_builder ("Test")
            .visibility (Visibility.PUBLIC)
            .add_method (method)
            .build ();

            string result = ValaFile.builder ().add_type (test_class).build ().to_string ();
            assert_true (result.contains ("if (x > 0) {\n"));
            assert_true (result.contains ("} else if (x < 0) {\n"));
            assert_true (result.contains ("} else {\n"));
        });

        Test.add_func ("/valapoet/code_block/loop_helpers", () => {
            var block = CodeBlock.builder ()
            .begin_foreach ("var item in items")
            .add_statement ("process (item)")
            .end_control_flow ()
            .begin_while ("running")
            .add_statement ("step ()")
            .end_control_flow ()
            .build ();

            var method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_code (block)
            .build ();

            var test_class = TypeSpec.class_builder ("Test")
            .visibility (Visibility.PUBLIC)
            .add_method (method)
            .build ();

            string result = ValaFile.builder ().add_type (test_class).build ().to_string ();
            assert_true (result.contains ("foreach (var item in items) {\n"));
            assert_true (result.contains ("while (running) {\n"));
        });

        Test.add_func ("/valapoet/code_block/try_catch_helpers", () => {
            var block = CodeBlock.builder ()
            .begin_try ()
            .add_statement ("do_risky_task ()")
            .begin_catch ("GLib.Error e")
            .add_statement ("log_error (e)")
            .begin_finally ()
            .add_statement ("cleanup ()")
            .end_control_flow ()
            .build ();

            var method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_code (block)
            .build ();

            var test_class = TypeSpec.class_builder ("Test")
            .visibility (Visibility.PUBLIC)
            .add_method (method)
            .build ();

            string result = ValaFile.builder ().add_type (test_class).build ().to_string ();
            assert_true (result.contains ("try {\n"));
            assert_true (result.contains ("} catch (GLib.Error e) {\n"));
            assert_true (result.contains ("} finally {\n"));
        });

        return Test.run ();
    }

}
