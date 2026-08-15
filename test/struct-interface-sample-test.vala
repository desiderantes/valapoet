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

public class StructInterfaceSampleTest : Object {

    public static void main(string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/struct_interface_sample",() => {
            var expected = """public struct Point {
	public double x;
	public double y;
}

public interface Printable : GLib.Object {
	public abstract string to_string ();
}

[Compact]
public class CompactNode {
	public int value;
}
""";
            var point_struct = TypeSpec.struct_builder ("Point")
                                .add_modifiers (ValaModifier.PUBLIC)
                                .add_field (FieldSpec.builder (TypeName.DOUBLE,"x").add_modifiers (ValaModifier.PUBLIC).build ())
                                .add_field (FieldSpec.builder (TypeName.DOUBLE,"y").add_modifiers (ValaModifier.PUBLIC).build ())
                                .build ();

            var printable_iface = TypeSpec.interface_builder ("Printable")
                                   .add_modifiers (ValaModifier.PUBLIC)
                                   .superclass (TypeName.OBJECT)
                                   .add_method (MethodSpec.method_builder ("to_string").add_modifiers (ValaModifier.PUBLIC,ValaModifier.ABSTRACT).returns (TypeName.STRING).build ())
                                   .build ();

            var compact_attr = AttributeSpec.builder ("Compact").build ();

            var compact_class = TypeSpec.class_builder ("CompactNode")
                                 .add_modifiers (ValaModifier.PUBLIC)
                                 .add_attribute (compact_attr)
                                 .add_field (FieldSpec.builder (TypeName.INT,"value").add_modifiers (ValaModifier.PUBLIC).build ())
                                 .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (point_struct)
                             .add_type (printable_iface)
                             .add_type (compact_class)
                             .build ();

            assert_true (vala_file.to_string () == expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/nested_type_newline_spacing",() => {
            var inner_class = TypeSpec.class_builder ("Inner")
                               .add_modifiers (ValaModifier.PUBLIC)
                               .build ();

            var outer_class = TypeSpec.class_builder ("Outer")
                               .add_modifiers (ValaModifier.PUBLIC)
                               .add_field (FieldSpec.builder (TypeName.INT,"val").add_modifiers (ValaModifier.PUBLIC).build ())
                               .add_type (inner_class)
                               .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (outer_class)
                             .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public int val;\n\n\tpublic class Inner {"));
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (code));
        });

        Test.run ();
    }

}
