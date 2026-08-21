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
            var err_domain = TypeSpec.error_domain_builder ("FileError")
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

            var status_enum = TypeSpec.enum_builder ("LogLevel")
            .visibility (Visibility.PUBLIC)
            .add_enum_constant ("DEBUG", 0)
            .add_enum_constant ("INFO", 1)
            .add_enum_constant ("ERROR", 2)
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

        Test.run ();
    }

}
