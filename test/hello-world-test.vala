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

public class HelloWorldTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/hello_world", () => {
            var expected_output = """namespace Demo {

	public class HelloWorld : GLib.Object {
		public static void main (string[] args) {
			stdout.printf ("Hello, World\n");
		}
	}
}
""";

            var main_method = MethodSpec.method_builder ("main")
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.STATIC)
            .returns (TypeName.VOID)
            .add_parameter (ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args").build ())
            .add_statement ("stdout.printf (\"Hello, World\\n\")")
            .build ();

            var hello_world_class = TypeSpec.class_builder ("HelloWorld")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (main_method)
            .build ();

            var demo_namespace = TypeSpec.namespace_builder ("Demo")
            .add_type (hello_world_class)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (demo_namespace)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected_output);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
