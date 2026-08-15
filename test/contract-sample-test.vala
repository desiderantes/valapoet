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

public class ContractSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/contract_sample", () => {
            var expected = """public void set_amount (int amount)
requires (amount > 0)
ensures (amount != 0) {
}
""";
            var method = MethodSpec.method_builder ("set_amount")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "amount").build ())
            .add_requires ("amount > 0")
            .add_ensures ("amount != 0")
            .build ();

            var vala_file = ValaFile.builder ()
            .add_method (method)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
