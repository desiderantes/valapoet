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

public class SignalSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/signal_spec/builder_and_parameters", () => {
            var signal = SignalSpec.builder ("clicked")
            .visibility (Visibility.PUBLIC)
            .add_comment ("Signal comment %s %d", "sig", 1)
            .add_valadoc ("Signal doc %s", "clicked")
            .returns (TypeName.BOOL)
            .add_parameter (ParameterSpec.builder (TypeName.INT, "x").build ())
            .add_parameter (ParameterSpec.builder (TypeName.INT, "y").build ())
            .build ();

            var test_class = TypeSpec.class_builder ("Button")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_signal (signal)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("// Signal comment sig 1"));
            assert_true (code.contains ("Signal doc clicked"));
            assert_true (code.contains ("public signal bool clicked (int x, int y);"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/signal_spec/modifiers_and_attributes", () => {
            var signal = SignalSpec.builder ("action_performed")
            .visibility (Visibility.PUBLIC)
            .add_modifiers (SymbolModifier.VIRTUAL)
            .build ();

            var test_class = TypeSpec.class_builder ("ActionWidget")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_signal (signal)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public virtual signal void action_performed ();"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
