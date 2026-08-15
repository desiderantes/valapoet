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
using ValaPoetTestUtil;

public class PropertySampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/property_overridden_and_custom", () => {
            var expected = """public class FooWidget : GLib.Object {
	public virtual string name {
		get; set;
	}
}

public class BaseWidget : FooWidget {
	private string _name;
	public virtual string title {
		get; set;
	}
	public string label {
		get; private set;
	}
	public override string name {
		get {
			return _name;
		}
		set {
			_name = value;
		}
	}
}
""";
            var foo_name_prop = PropertySpec.builder (TypeName.STRING, "name")
            .add_modifiers (ValaModifier.PUBLIC, ValaModifier.VIRTUAL)
            .auto ()
            .build ();

            var foo_class = TypeSpec.class_builder ("FooWidget")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_property (foo_name_prop)
            .build ();

            var title_prop = PropertySpec.builder (TypeName.STRING, "title")
            .add_modifiers (ValaModifier.PUBLIC, ValaModifier.VIRTUAL)
            .auto ()
            .build ();

            var label_prop = PropertySpec.builder (TypeName.STRING, "label")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_set_modifiers (ValaModifier.PRIVATE)
            .build ();

            var get_code = CodeBlock.builder ().add_statement ("return _name").build ();
            var set_code = CodeBlock.builder ().add_statement ("_name = value").build ();

            var name_prop = PropertySpec.builder (TypeName.STRING, "name")
            .add_modifiers (ValaModifier.PUBLIC, ValaModifier.OVERRIDE)
            .get_body (get_code)
            .set_body (set_code)
            .build ();

            var name_field = FieldSpec.builder (TypeName.STRING, "_name")
            .add_modifiers (ValaModifier.PRIVATE)
            .build ();

            var widget_class = TypeSpec.class_builder ("BaseWidget")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (ClassName.get ("", "FooWidget"))
            .add_field (name_field)
            .add_property (title_prop)
            .add_property (label_prop)
            .add_property (name_prop)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (foo_class)
            .add_type (widget_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
