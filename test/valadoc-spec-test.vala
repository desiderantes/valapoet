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

public class ValadocSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/valadoc_spec/builder_and_formatting", () => {
            var doc = ValadocSpec.builder ()
            .summary ("Calculates sum of two numbers.")
            .description ("Adds number A to number B.")
            .add_param ("a", "First number")
            .add_param ("b", "Second number")
            .returns ("The arithmetic sum")
            .@throws ("GLib.Error", "On overflow")
            .since ("1.0")
            .deprecated ("Use add_all instead")
            .see ("Calculator.add")
            .build ();

            var method = MethodSpec.method_builder ("add")
            .add_valadoc_spec (doc)
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.INT)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "a").build ())
            .add_parameter (ParameterSpec.builder (TypeName.INT, "b").build ())
            .add_statement ("return a + b")
            .build ();

            var calc_class = TypeSpec.class_builder ("Calculator")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (calc_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("Calculates sum of two numbers."));
            assert_true (code.contains ("Adds number A to number B."));
            assert_true (code.contains ("@param a First number"));
            assert_true (code.contains ("@param b Second number"));
            assert_true (code.contains ("@return The arithmetic sum"));
            assert_true (code.contains ("@throws GLib.Error On overflow"));
            assert_true (code.contains ("@since 1.0"));
            assert_true (code.contains ("@deprecated Use add_all instead"));
            assert_true (code.contains ("@see Calculator.add"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/valadoc_spec/inherit_doc_and_link", () => {
            var doc = ValadocSpec.builder ()
            .inherit_doc ()
            .description ("Overridden implementation referencing " + ValadocSpec.link ("GLib.Object"))
            .build ();

            var method = MethodSpec.method_builder ("foo")
            .add_valadoc_spec (doc)
            .visibility (Visibility.PUBLIC)
            .build ();

            var dummy = TypeSpec.class_builder ("Dummy")
            .visibility (Visibility.PUBLIC)
            .add_method (method)
            .build ();

            string output = ValaFile.builder ().add_type (dummy).build ().to_string ();
            assert_true (output.contains ("{@inheritDoc}"));
            assert_true (output.contains ("{@link GLib.Object}"));
        });

        return Test.run ();
    }

}
