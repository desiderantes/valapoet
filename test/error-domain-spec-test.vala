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

public class ErrorDomainSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/error_domain_spec/builder", () => {
            var domain = ErrorDomainSpec.builder ("DatabaseError")
            .visibility (Visibility.PUBLIC)
            .add_error_code ("CONNECTION_FAILED")
            .add_error_code ("QUERY_SYNTAX")
            .add_error_code ("TIMEOUT")
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (domain)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public errordomain DatabaseError {\n"));
            assert_true (code.contains ("CONNECTION_FAILED,\n"));
            assert_true (code.contains ("QUERY_SYNTAX,\n"));
            assert_true (code.contains ("TIMEOUT\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
