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

public class MethodsSyntaxSupportTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/methods_syntax_support", () => {
            var expected = """public class CustomCollection : GLib.Object {
	public string get (int index) {
		return "item";
	}

	public void set (int index, string item) {
	}

	public bool contains (string needle) {
		return true;
	}

	public string to_string () {
		return "CustomCollection";
	}
}
""";
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

            var to_string_method = MethodSpec.method_builder ("to_string")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING)
            .add_statement ("return \"CustomCollection\"")
            .build ();

            var coll_class = TypeSpec.class_builder ("CustomCollection")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (get_method)
            .add_method (set_method)
            .add_method (contains_method)
            .add_method (to_string_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (coll_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/control_flow_helpers", () => {
            var expected = """public class FlowHelper : GLib.Object {
	public void run (string[] items) {
		foreach (var item in items) {
			if (item == "skip") {
				continue;
			} else if (item == "stop") {
				break;
			} else {
				stdout.printf ("Item: %s\n", item);
			}
		}
		try {
			int x = 0;
			while (x < 3) {
				x++;
			}
		} catch (GLib.Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}
}
""";
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
            .begin_try ()
                .add_statement ("int x = 0")
                .begin_while ("x < 3")
                    .add_statement ("x++")
                .end_control_flow ()
            .begin_catch ("GLib.Error e")
                .add_statement ("stderr.printf (\"Error: %s\\n\", e.message)")
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

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/nested_enum_with_method", () => {
            var enum_to_string = MethodSpec.method_builder ("to_string")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING)
            .add_statement ("return \"NONE\"")
            .build ();

            var feature_enum = EnumSpec.builder ("Feature")
            .visibility (Visibility.PUBLIC)
            .add_constant ("NONE", 0)
            .add_method (enum_to_string)
            .build ();

            var outer_class = TypeSpec.class_builder ("Outer")
            .visibility (Visibility.PUBLIC)
            .add_type (feature_enum)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (outer_class)
            .build ();

            var generated = vala_file.to_string ();
            var expected = """public class Outer {
	public enum Feature {
		NONE = 0;

		public string to_string () {
			return "NONE";
		}
	}
}
""";
            assert_cmpstr (generated, GLib.CompareOperator.EQ, expected);
        });

        Test.add_func ("/valapoet/valadoc_spec_builder", () => {
            var doc = ValadocSpec.builder ()
            .summary ("Calculates sum of two numbers.")
            .description ("Adds number A to number B.")
            .add_param ("a", "First number")
            .add_param ("b", "Second number")
            .returns ("The arithmetic sum")
            .@throws ("GLib.Error", "On overflow")
            .since ("1.0")
            .deprecated ("Use add_all instead")
            .see ("Calculator.add")
            .build ();

            var add_method = MethodSpec.method_builder ("add")
            .visibility (Visibility.PUBLIC)
            .add_valadoc_spec (doc)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "a").build ())
            .add_parameter (ParameterSpec.builder (TypeName.INT, "b").build ())
            .returns (TypeName.INT)
            .add_statement ("return a + b")
            .build ();

            var calc_class = TypeSpec.class_builder ("Calculator")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (add_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (calc_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("/**\n"));
            assert_true (code.contains (" * Calculates sum of two numbers.\n"));
            assert_true (code.contains (" * Adds number A to number B.\n"));
            assert_true (code.contains (" * @param a First number\n"));
            assert_true (code.contains (" * @param b Second number\n"));
            assert_true (code.contains (" * @return The arithmetic sum\n"));
            assert_true (code.contains (" * @throws GLib.Error On overflow\n"));
            assert_true (code.contains (" * @since 1.0\n"));
            assert_true (code.contains (" * @deprecated Use add_all instead\n"));
            assert_true (code.contains (" * @see Calculator.add\n"));
            assert_true (code.contains (" */\n"));
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (code));
        });

        Test.run ();
    }
}
