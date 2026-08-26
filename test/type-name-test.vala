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

public class TypeNameTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/type_name/primitives", () => {
            assert_cmpstr (TypeName.INT.to_string (), GLib.CompareOperator.EQ, "int");
            assert_cmpstr (TypeName.STRING.to_string (), GLib.CompareOperator.EQ, "string");
            assert_cmpstr (TypeName.BOOL.to_string (), GLib.CompareOperator.EQ, "bool");
            assert_cmpstr (TypeName.OBJECT.to_string (), GLib.CompareOperator.EQ, "GLib.Object");
        });

        Test.add_func ("/valapoet/type_name/ownership_and_nullability", () => {
            TypeName nullable_int = TypeName.INT.nullable ();
            assert_true (nullable_int.is_nullable);

            TypeName unowned_obj = TypeName.OBJECT.@unowned ();
            assert_true (unowned_obj.is_unowned);

            TypeName weak_obj = TypeName.OBJECT.@weak ();
            assert_true (weak_obj.is_weak);

            TypeName owned_obj = TypeName.OBJECT.@owned ();
            assert_true (owned_obj.is_owned);

            // Copy preservation check
            TypeName copy_unowned = unowned_obj.copy ();
            assert_true (copy_unowned.is_unowned);
        });

        Test.add_func ("/valapoet/type_name/array_types", () => {
            var int_array = new ArrayTypeName (TypeName.INT, 1);
            assert_cmpint (int_array.rank, GLib.CompareOperator.EQ, 1);
            assert_cmpstr (int_array.component_type.to_string (), GLib.CompareOperator.EQ, "int");

            var int_matrix = new ArrayTypeName (TypeName.INT, 2);
            assert_cmpint (int_matrix.rank, GLib.CompareOperator.EQ, 2);
        });

        Test.add_func ("/valapoet/type_name/parameterized_types", () => {
            ClassName map_type = ClassName.get ("Gee", "HashMap");
            ParameterizedTypeName param_map = new ParameterizedTypeName.of (map_type, TypeName.STRING, TypeName.STRING);

            var field = FieldSpec.builder (param_map, "items")
            .visibility (Visibility.PUBLIC)
            .build ();

            var test_class = TypeSpec.class_builder ("Container")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (field)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("items;"));
            assert_true (CodeCompiler.verify_code_compiles (code, { "gee-0.8" }));
        });

        return Test.run ();
    }

}
