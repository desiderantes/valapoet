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

    public static void main(string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/error_domain_sample",() => {
            var expected = """public errordomain FileError {
	NOT_FOUND,
	PERMISSION_DENIED
}
""";
            var err_domain = TypeSpec.error_domain_builder ("FileError")
                              .add_modifiers (ValaModifier.PUBLIC)
                              .add_error_code ("NOT_FOUND")
                              .add_error_code ("PERMISSION_DENIED")
                              .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (err_domain)
                             .build ();

            assert_true (vala_file.to_string () == expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
