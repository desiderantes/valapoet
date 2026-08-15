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

public class NameAllocatorTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/name_allocator", () => {
            var allocator = new NameAllocator ();
            assert_cmpstr (allocator.new_name ("class"), GLib.CompareOperator.EQ, "@class");
            assert_cmpstr (allocator.new_name ("class"), GLib.CompareOperator.EQ, "@class_2");
            assert_cmpstr (allocator.new_name ("signal"), GLib.CompareOperator.EQ, "@signal");
            assert_cmpstr (allocator.new_name ("int"), GLib.CompareOperator.EQ, "_int");
            assert_cmpstr (allocator.new_name ("foo"), GLib.CompareOperator.EQ, "foo");
            assert_cmpstr (allocator.new_name ("foo"), GLib.CompareOperator.EQ, "foo_2");
            assert_cmpstr (allocator.new_name ("123abc"), GLib.CompareOperator.EQ, "_123abc");
        });

        Test.add_func ("/valapoet/super_class_name_collision_resolution", () => {
            var base_type = ClassName.get ("Framework.Core", "Widget");
            var derived_class = TypeSpec.class_builder ("Widget")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (base_type)
            .build ();

            var ui_namespace = TypeSpec.namespace_builder ("App.UI")
            .add_type (derived_class)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (ui_namespace)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public class Widget : Framework.Core.Widget"));
            assert_false (code.contains ("public class Widget : Widget"));

            string dummy_context = """
            namespace Framework.Core {
                public class Widget : GLib.Object {}
            }

            namespace App.UI {
                public class Widget : Framework.Core.Widget {
                }
            }
            """;
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (dummy_context));
        });

        Test.run ();
    }

}
