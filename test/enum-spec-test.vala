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

public class EnumSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/enum_spec/constants_and_methods", () => {
            var enum_spec = EnumSpec.builder ("Status")
            .visibility (Visibility.PUBLIC)
            .add_constant ("IDLE")
            .add_constant ("RUNNING")
            .add_constant ("FINISHED")
            .add_method (
                MethodSpec.method_builder ("to_display_string")
                .visibility (Visibility.PUBLIC)
                .returns (TypeName.STRING)
                .begin_switch ("this")
                .add_statement ("case IDLE: return \"Idle\"")
                .add_statement ("case RUNNING: return \"Running\"")
                .add_statement ("case FINISHED: return \"Finished\"")
                .add_statement ("default: return \"Unknown\"")
                .end_control_flow ()
                .build ()
            )
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (enum_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public enum Status {\n"));
            assert_true (code.contains ("IDLE,\n"));
            assert_true (code.contains ("public string to_display_string () {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
