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

public class GeeListSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/gee_list_sample", () => {
            var expected_output = """using Gee;

void main () {
	var list = new ArrayList<int> ();
	list.add (1);
	list.add (2);
	list.add (5);
	list.add (4);
	list.insert (2, 3);
	list.remove_at (3);
	foreach (int i in list) {
		stdout.printf ("%d\n", i);
	}
	list[2] = 10;
	stdout.printf ("%d\n", list[2]);
}
""";
            var array_list_type = new ParameterizedTypeName.of (ClassName.get ("Gee", "ArrayList"), TypeName.INT);

            var main_method = MethodSpec.method_builder ("main")
            .add_statement ("var list = new %T ()", array_list_type)
            .add_statement ("list.add (1)")
            .add_statement ("list.add (2)")
            .add_statement ("list.add (5)")
            .add_statement ("list.add (4)")
            .add_statement ("list.insert (2, 3)")
            .add_statement ("list.remove_at (3)")
            .begin_control_flow ("foreach (int i in list)")
            .add_statement ("stdout.printf (\"%d\\n\", i)")
            .end_control_flow ()
            .add_statement ("list[2] = 10")
            .add_statement ("stdout.printf (\"%d\\n\", list[2])")
            .build ();

            var vala_file = ValaFile.builder ()
            .add_using ("Gee")
            .add_method (main_method)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected_output);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
