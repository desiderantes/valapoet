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

public class OwnershipSampleTest : Object {

    public static void main(string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/ownership_sample", () => {
            var expected = """public class Node : GLib.Object {
	public weak Node? parent;
	public string data;
	public unowned Node get_parent () {
		return parent;
	}

	public void set_node_data (owned string data) {
		this.data = (owned) data;
	}
}
""";
            var parent_type = ClassName.get ("", "Node").copy ();
            parent_type.is_weak = true;
            parent_type.is_nullable = true;

            var parent_field = FieldSpec.builder (parent_type, "parent")
                                .add_modifiers (ValaModifier.PUBLIC)
                                .build ();

            var data_field = FieldSpec.builder (TypeName.STRING, "data")
                              .add_modifiers (ValaModifier.PUBLIC)
                              .build ();

            var unowned_ret_type = ClassName.get ("", "Node").copy ();
            unowned_ret_type.is_unowned = true;

            var get_parent_method = MethodSpec.method_builder ("get_parent")
                                     .add_modifiers (ValaModifier.PUBLIC)
                                     .returns (unowned_ret_type)
                                     .add_statement ("return parent")
                                     .build ();

            var owned_param_type = TypeName.STRING.copy ();
            owned_param_type.is_owned = true;

            var set_data_param = ParameterSpec.builder (owned_param_type, "data").build ();

            var set_data_method = MethodSpec.method_builder ("set_node_data")
                                   .add_modifiers (ValaModifier.PUBLIC)
                                   .add_parameter (set_data_param)
                                   .add_statement ("this.data = (owned) data")
                                   .build ();

            var node_class = TypeSpec.class_builder ("Node")
                              .add_modifiers (ValaModifier.PUBLIC)
                              .superclass (TypeName.OBJECT)
                              .add_field (parent_field)
                              .add_field (data_field)
                              .add_method (get_parent_method)
                              .add_method (set_data_method)
                              .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (node_class)
                             .build ();

            var actual = vala_file.to_string ();
            if (actual != expected) {
                stdout.printf ("ACTUAL:\n'%s'\nEXPECTED:\n'%s'\n", actual, expected);
            }
            assert_true (actual == expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
