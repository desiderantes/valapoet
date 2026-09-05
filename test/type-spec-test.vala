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

public class TypeSpecTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/type_spec/class_builder", () => {
            var class_spec = TypeSpec.class_builder ("Person")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (FieldSpec.builder (TypeName.STRING, "name").visibility (Visibility.PUBLIC).build ())
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (class_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public class Person : GLib.Object {\n"));
            assert_true (code.contains ("public string name;\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/type_spec/formatted_comments_and_docstrings", () => {
            var class_spec = TypeSpec.class_builder ("FormattedItem")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_comment ("Version %d of %s", 2, "Widget")
                .add_valadoc ("Docstring for %s", "FormattedItem")
                .build ();

            var vala_file = ValaFile.builder ()
                .add_type (class_spec)
                .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("// Version 2 of Widget"));
            assert_true (code.contains ("Docstring for FormattedItem"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/type_spec/struct_builder", () => {
            var struct_spec = TypeSpec.struct_builder ("Point2D")
            .visibility (Visibility.PUBLIC)
            .add_field (FieldSpec.builder (TypeName.DOUBLE, "x").visibility (Visibility.PUBLIC).build ())
            .add_field (FieldSpec.builder (TypeName.DOUBLE, "y").visibility (Visibility.PUBLIC).build ())
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (struct_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public struct Point2D {\n"));
            assert_true (code.contains ("public double x;\n"));
            assert_true (code.contains ("public double y;\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/type_spec/interface_builder", () => {
            var iface_spec = TypeSpec.interface_builder ("Printable")
            .visibility (Visibility.PUBLIC)
            .add_method (
                MethodSpec.method_builder ("print")
                .visibility (Visibility.PUBLIC)
                .add_modifiers (SymbolModifier.ABSTRACT)
                .build ()
            )
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (iface_spec)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public interface Printable {\n"));
            assert_true (code.contains ("public abstract void print ();\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/type_spec/abstract_class_validation", () => {
            var abs_method = MethodSpec.method_builder ("draw")
                .visibility (Visibility.PUBLIC)
                .add_modifiers (SymbolModifier.ABSTRACT)
                .build ();

            var abs_class = TypeSpec.class_builder ("Shape")
                .visibility (Visibility.PUBLIC)
                .add_modifiers (SymbolModifier.ABSTRACT)
                .superclass (TypeName.OBJECT)
                .add_method (abs_method)
                .build ();

            var vala_file = ValaFile.builder ()
                .add_type (abs_class)
                .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public abstract class Shape : GLib.Object {\n"));
            assert_true (code.contains ("public abstract void draw ();\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/type_spec/non_abstract_class_with_abstract_method_fails", () => {
            Test.trap_subprocess ("/valapoet/type_spec/non_abstract_class_with_abstract_method_fails/subprocess", 0, 0);
            Test.trap_assert_failed ();
            Test.trap_assert_stderr ("*class with abstract methods must be abstract*");
        });

        Test.add_func ("/valapoet/type_spec/non_abstract_class_with_abstract_method_fails/subprocess", () => {
            var abs_method = MethodSpec.method_builder ("draw")
                .visibility (Visibility.PUBLIC)
                .add_modifiers (SymbolModifier.ABSTRACT)
                .build ();

            TypeSpec.class_builder ("NonAbstractShape")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_method (abs_method)
                .build ();
        });

        Test.add_func ("/valapoet/type_spec/symbol_comments", () => {
            var field = FieldSpec.builder (TypeName.INT, "counter")
            .add_comment ("Regular non-docstring field comment")
            .visibility (Visibility.PRIVATE)
            .build ();

            var test_class = TypeSpec.class_builder ("CommentWidget")
            .add_comment ("Regular non-docstring class comment")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (field)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("// Regular non-docstring class comment\n"));
            assert_true (code.contains ("// Regular non-docstring field comment\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
