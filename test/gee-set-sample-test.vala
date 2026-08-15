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

public class GeeSetSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/gee_set_sample", () => {
            var expected_output = """using Gee;

void main () {
	var my_set = new HashSet<string> ();
	my_set.add ("one");
	my_set.add ("two");
	my_set.add ("three");
	my_set.add ("two");
	foreach (string s in my_set) {
		stdout.printf ("%s\n", s);
	}
}
""";
            var hash_set_type = new ParameterizedTypeName.of (ClassName.get ("Gee", "HashSet"), TypeName.STRING);

            var main_method = MethodSpec.method_builder ("main")
            .add_statement ("var my_set = new %T ()", hash_set_type)
            .add_statement ("my_set.add (\"one\")")
            .add_statement ("my_set.add (\"two\")")
            .add_statement ("my_set.add (\"three\")")
            .add_statement ("my_set.add (\"two\")")
            .begin_control_flow ("foreach (string s in my_set)")
            .add_statement ("stdout.printf (\"%s\\n\", s)")
            .end_control_flow ()
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
