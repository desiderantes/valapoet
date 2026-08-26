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

public class FieldSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/field_spec/builder_and_modifiers", () => {
            var field = FieldSpec.builder (TypeName.INT, "counter")
            .visibility (Visibility.PUBLIC)
            .add_modifiers (SymbolModifier.STATIC)
            .initializer ("42")
            .build ();

            var test_class = TypeSpec.class_builder ("Settings")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (field)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public static int counter = 42;"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/field_spec/ownership_modifiers", () => {
            var unowned_field = FieldSpec.builder (TypeName.OBJECT.@unowned (), "parent")
            .visibility (Visibility.PRIVATE)
            .build ();

            var test_class = TypeSpec.class_builder ("Node")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (unowned_field)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("private unowned GLib.Object parent;"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
