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

public class GenericsSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/generics_sample", () => {
            var expected = """public class Container<G> : GLib.Object {
	public void process<T> (T item) {
	}
}
""";
            var tv_g = TypeVariableName.get ("G");
            var tv_t = TypeVariableName.get ("T");

            var process_method = MethodSpec.method_builder ("process")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_type_variable (tv_t)
            .add_parameter (ParameterSpec.builder (tv_t, "item").build ())
            .build ();

            var container_class = TypeSpec.class_builder ("Container")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_type_variable (tv_g)
            .superclass (TypeName.OBJECT)
            .add_method (process_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (container_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
