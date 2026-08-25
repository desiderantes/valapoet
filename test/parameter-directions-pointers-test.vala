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

public class ParameterDirectionsPointersTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/parameter_directions_pointers", () => {
            var expected = """public class BaseHandler : GLib.Object {
	public void process_data (int input, out int output, ref int status) {
		output = input * 2;
		status = 1;
	}
}

public class CustomHandler : BaseHandler {
	public new void process_data (int input, out int output, ref int status) {
		output = input * 3;
	}

	public void handle_raw_pointer (void* ptr, int[,] matrix) {
	}
}
""";
            var p_input = ParameterSpec.builder (TypeName.INT, "input").build ();

            var p_output = ParameterSpec.builder (TypeName.INT, "output")
            .direction (ParameterDirection.OUT)
            .build ();

            var p_status = ParameterSpec.builder (TypeName.INT, "status")
            .direction (ParameterDirection.REF)
            .build ();

            var base_process = MethodSpec.method_builder ("process_data")
            .visibility (Visibility.PUBLIC)
            .add_parameter (p_input)
            .add_parameter (p_output)
            .add_parameter (p_status)
            .add_statement ("output = input * 2")
            .add_statement ("status = 1")
            .build ();

            var base_class = TypeSpec.class_builder ("BaseHandler")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (base_process)
            .build ();

            var hide_process = MethodSpec.method_builder ("process_data")
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.NEW)
            .add_parameter (p_input)
            .add_parameter (p_output)
            .add_parameter (p_status)
            .add_statement ("output = input * 3")
            .build ();

            var void_ptr_type = TypeName.VOID.pointer_to ();
            var matrix_type = new ArrayTypeName.of (TypeName.INT, 2);

            var raw_method = MethodSpec.method_builder ("handle_raw_pointer")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (void_ptr_type, "ptr").build ())
            .add_parameter (ParameterSpec.builder (matrix_type, "matrix").build ())
            .build ();

            var custom_class = TypeSpec.class_builder ("CustomHandler")
            .visibility (Visibility.PUBLIC)
            .superclass (ClassName.get ("", "BaseHandler"))
            .add_method (hide_process)
            .add_method (raw_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (base_class)
            .add_type (custom_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/null_terminated_array_parameter", () => {
            var expected = """public class ExecHelper : GLib.Object {
	public void run ([CCode (array_length = false, array_null_terminated = true)] string[] args) {
	}
}
""";
            var null_term_attr = AttributeSpec.builder ("CCode")
            .add_argument ("array_length", "false")
            .add_argument ("array_null_terminated", "true")
            .build ();

            var param = ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args")
            .add_attribute (null_term_attr)
            .build ();

            var run_method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_parameter (param)
            .build ();

            var exec_class = TypeSpec.class_builder ("ExecHelper")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (run_method)
            .build ();

            var vala_file_nt = ValaFile.builder ()
            .add_type (exec_class)
            .build ();

            assert_cmpstr (vala_file_nt.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file_nt.to_string ()));
        });

        Test.add_func ("/valapoet/multiple_joined_parameter_attributes", () => {
            var expected = """public class MultiAttrHelper : GLib.Object {
	public void run ([CCode (array_length = false, array_null_terminated = true), Version (since = "1.0")] string[] args) {
	}
}
""";
            var ccode_attr = AttributeSpec.builder ("CCode")
            .add_argument ("array_length", "false")
            .add_argument ("array_null_terminated", "true")
            .build ();

            var ver_attr = AttributeSpec.builder ("Version")
            .add_argument ("since", "\"1.0\"")
            .build ();

            var param = ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args")
            .add_attribute (ccode_attr)
            .add_attribute (ver_attr)
            .build ();

            var run_method = MethodSpec.method_builder ("run")
            .visibility (Visibility.PUBLIC)
            .add_parameter (param)
            .build ();

            var exec_class = TypeSpec.class_builder ("MultiAttrHelper")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (run_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (exec_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/primitive_type_helpers", () => {
            var buffer_class = TypeSpec.class_builder ("BufferContainer")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (FieldSpec.builder (TypeName.SIZE_T, "size").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.SSIZE_T, "ssize").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.UINT32, "id32").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.INT64, "id64").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.UINT64, "uid64").visibility (Visibility.PUBLIC).build ())
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (buffer_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public size_t size;"));
            assert_true (code.contains ("public ssize_t ssize;"));
            assert_true (code.contains ("public uint32 id32;"));
            assert_true (code.contains ("public int64 id64;"));
            assert_true (code.contains ("public uint64 uid64;"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.run ();
    }

}
