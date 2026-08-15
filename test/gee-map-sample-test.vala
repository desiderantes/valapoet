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

public class GeeMapSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/gee_map_sample", () => {
            var expected_output = """using Gee;

void main () {
	var map = new HashMap<string, int> ();
	map.set ("one", 1);
	map.set ("two", 2);
	map.set ("three", 3);
	map["four"] = 4;
	map["five"] = 5;
	int a = map.get ("four");
	int b = map["four"];
	assert (a == b);
	stdout.printf ("Iterating over entries\n");
	foreach (var entry in map.entries) {
		stdout.printf ("%s => %d\n", entry.key, entry.value);
	}
	stdout.printf ("Iterating over keys only\n");
	foreach (string key in map.keys) {
		stdout.printf ("%s\n", key);
	}
	stdout.printf ("Iterating over values only\n");
	foreach (int value in map.values) {
		stdout.printf ("%d\n", value);
	}
	stdout.printf ("Iterating via 'for' statement\n");
	var it = map.map_iterator ();
	for (var has_next = it.next (); has_next; has_next = it.next ()) {
		stdout.printf ("%d\n", it.get_value ());
	}
}
""";
            var map_type = new ParameterizedTypeName.of (
                    ClassName.get ("Gee", "HashMap"),
                    TypeName.STRING, TypeName.INT
            );

            var main_method = MethodSpec.method_builder ("main")
            .add_statement ("var map = new %T ()", map_type)
            .add_statement ("map.set (\"one\", 1)")
            .add_statement ("map.set (\"two\", 2)")
            .add_statement ("map.set (\"three\", 3)")
            .add_statement ("map[\"four\"] = 4")
            .add_statement ("map[\"five\"] = 5")
            .add_statement ("int a = map.get (\"four\")")
            .add_statement ("int b = map[\"four\"]")
            .add_statement ("assert (a == b)")
            .add_statement ("stdout.printf (\"Iterating over entries\\n\")")
            .begin_control_flow ("foreach (var entry in map.entries)")
            .add_statement ("stdout.printf (\"%s => %d\\n\", entry.key, entry.value)")
            .end_control_flow ()
            .add_statement ("stdout.printf (\"Iterating over keys only\\n\")")
            .begin_control_flow ("foreach (string key in map.keys)")
            .add_statement ("stdout.printf (\"%s\\n\", key)")
            .end_control_flow ()
            .add_statement ("stdout.printf (\"Iterating over values only\\n\")")
            .begin_control_flow ("foreach (int value in map.values)")
            .add_statement ("stdout.printf (\"%d\\n\", value)")
            .end_control_flow ()
            .add_statement ("stdout.printf (\"Iterating via 'for' statement\\n\")")
            .add_statement ("var it = map.map_iterator ()")
            .begin_control_flow ("for (var has_next = it.next (); has_next; has_next = it.next ())")
            .add_statement ("stdout.printf (\"%d\\n\", it.get_value ())")
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
