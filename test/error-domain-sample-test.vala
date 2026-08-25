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

public class ErrorDomainSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/error_domain_sample", () => {
            var expected = """public errordomain FileError {
	NOT_FOUND,
	PERMISSION_DENIED
}
""";
            var err_domain = ErrorDomainSpec.builder ("FileError")
            .visibility (Visibility.PUBLIC)
            .add_error_code ("NOT_FOUND")
            .add_error_code ("PERMISSION_DENIED")
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (err_domain)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/enum_constant_spec", () => {
            var to_string_method = MethodSpec.method_builder ("to_string_name")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING)
            .add_statement ("return \"LogLevel\"")
            .build ();

            var status_enum = EnumSpec.builder ("LogLevel")
            .visibility (Visibility.PUBLIC)
            .add_constant ("DEBUG", 0)
            .add_constant ("INFO", 1)
            .add_constant ("ERROR", 2)
            .add_method (to_string_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (status_enum)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("DEBUG = 0,\n"));
            assert_true (code.contains ("INFO = 1,\n"));
            assert_true (code.contains ("ERROR = 2;\n"));
            assert_true (code.contains ("public string to_string_name ()"));
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/dedicated_enum_spec_and_error_domain_spec", () => {
            var err_domain = ErrorDomainSpec.builder ("NetError")
            .visibility (Visibility.PUBLIC)
            .add_error_code ("TIMEOUT")
            .add_error_code ("REFUSED")
            .build ();

            var print_method = MethodSpec.method_builder ("print_info")
            .visibility (Visibility.PUBLIC)
            .add_statement ("stdout.printf (\"State\\n\")")
            .build ();

            var state_enum = EnumSpec.builder ("State")
            .visibility (Visibility.PUBLIC)
            .add_constant ("INIT", 1)
            .add_constant ("RUNNING", 2)
            .add_method (print_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (err_domain)
            .add_type (state_enum)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public errordomain NetError {\n\tTIMEOUT,\n\tREFUSED\n}\n"));
            assert_true (code.contains ("public enum State {\n\tINIT = 1,\n\tRUNNING = 2;\n"));
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (code));
        });

        Test.run ();
    }

}
