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

public class ParameterSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/parameter_spec/directions_and_defaults", () => {
            var out_param = ParameterSpec.builder (TypeName.INT, "result")
            .direction (ParameterDirection.OUT)
            .build ();

            var ref_param = ParameterSpec.builder (TypeName.STRING, "buffer")
            .direction (ParameterDirection.REF)
            .build ();

            var default_param = ParameterSpec.builder (TypeName.INT, "flags")
            .default_value ("0")
            .build ();

            var method = MethodSpec.method_builder ("process")
            .visibility (Visibility.PUBLIC)
            .add_parameter (out_param)
            .add_parameter (ref_param)
            .add_parameter (default_param)
            .add_statement ("result = 42")
            .build ();

            var test_class = TypeSpec.class_builder ("Processor")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("out int result"));
            assert_true (code.contains ("ref string buffer"));
            assert_true (code.contains ("int flags = 0"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/parameter_spec/ownership_and_params", () => {
            var owned_param = ParameterSpec.builder (TypeName.OBJECT.@owned (), "handler")
            .build ();

            var params_arg = ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args")
            .@params ()
            .build ();

            var method = MethodSpec.method_builder ("register")
            .visibility (Visibility.PUBLIC)
            .add_parameter (owned_param)
            .add_parameter (params_arg)
            .build ();

            var test_class = TypeSpec.class_builder ("Registry")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("owned GLib.Object handler"));
            assert_true (code.contains ("params string[] args"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
