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

        Test.add_func ("/valapoet/nested_enum_with_method", () => {
            var enum_to_string = MethodSpec.method_builder ("to_string")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING)
            .add_statement ("return \"NONE\"")
            .build ();

            var feature_enum = TypeSpec.enum_builder ("Feature")
            .visibility (Visibility.PUBLIC)
            .add_enum_constant ("NONE", 0)
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

        Test.run ();
    }
}
