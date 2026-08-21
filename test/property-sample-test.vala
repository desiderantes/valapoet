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
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.VIRTUAL)
            .auto ()
            .build ();

            var foo_class = TypeSpec.class_builder ("FooWidget")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_property (foo_name_prop)
            .build ();

            var title_prop = PropertySpec.builder (TypeName.STRING, "title")
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.VIRTUAL)
            .auto ()
            .build ();

            var label_prop = PropertySpec.builder (TypeName.STRING, "label")
            .visibility (Visibility.PUBLIC)
            .private_set ()
            .build ();

            var get_code = CodeBlock.builder ().add_statement ("return _name").build ();
            var set_code = CodeBlock.builder ().add_statement ("_name = value").build ();

            var name_prop = PropertySpec.builder (TypeName.STRING, "name")
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.OVERRIDE)
            .get_body (get_code)
            .set_body (set_code)
            .build ();

            var name_field = FieldSpec.builder (TypeName.STRING, "_name")
            .visibility (Visibility.PRIVATE)
            .build ();

            var widget_class = TypeSpec.class_builder ("BaseWidget")
            .visibility (Visibility.PUBLIC)
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

        Test.add_func ("/valapoet/read_only_and_owned_property", () => {
            var owned_str_type = TypeName.STRING.copy ();
            owned_str_type.is_owned = true;

            var prop = PropertySpec.builder (owned_str_type, "status")
                       .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.ABSTRACT)
                       .read_only ()
                       .build ();

            var iface = TypeSpec.interface_builder ("IDemo")
                        .visibility (Visibility.PUBLIC)
                        .prerequisite (ClassName.get ("GLib", "Object"))
                        .add_property (prop)
                        .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (iface)
                             .build ();

            var expected = """public interface IDemo : GLib.Object {
	public abstract string status {
		owned get;
	}
}
""";
            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/builder_convenience_methods", () => {
            var prop1 = PropertySpec.builder (TypeName.INT, "count")
                        .visibility (Visibility.PUBLIC)
                        .private_set ()
                        .default_value ("10")
                        .build ();

            var prop2 = PropertySpec.builder (TypeName.STRING, "tag")
                        .visibility (Visibility.PUBLIC)
                        .construct_only ()
                        .build ();

            var widget_class = TypeSpec.class_builder ("Counter")
                               .visibility (Visibility.PUBLIC)
                               .superclass (ClassName.get ("GLib", "Object"))
                               .add_property (prop1)
                               .add_property (prop2)
                               .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (widget_class)
                             .build ();

            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
