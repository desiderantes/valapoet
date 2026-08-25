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

public class ConstructorsDestructorsSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/constructors_destructors_sample", () => {
            var expected = """public class Widget : GLib.Object {
	public string name;
	static construct {
		stdout.printf ("Static initialized\n");
	}
	construct {
		stdout.printf ("Object constructed\n");
	}

	public Widget () {
		this.name = "default";
	}

	public Widget.with_name (string name) {
		this.name = name;
	}

	~Widget () {
		stdout.printf ("Destroyed\n");
	}
}
""";
            var name_field = FieldSpec.builder (TypeName.STRING, "name")
            .visibility (Visibility.PUBLIC)
            .build ();

            var static_block = CodeBlock.builder ().add_statement ("stdout.printf (\"Static initialized\\n\")").build ();
            var instance_block = CodeBlock.builder ().add_statement ("stdout.printf (\"Object constructed\\n\")").build ();

            var default_ctor = MethodSpec.constructor_builder ()
            .visibility (Visibility.PUBLIC)
            .add_statement ("this.name = \"default\"")
            .build ();

            var named_ctor = MethodSpec.named_constructor_builder ("with_name")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "name").build ())
            .add_statement ("this.name = name")
            .build ();

            var destructor = MethodSpec.destructor_builder ()
            .add_statement ("stdout.printf (\"Destroyed\\n\")")
            .build ();

            var widget_class = TypeSpec.class_builder ("Widget")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_field (name_field)
            .set_static_construct_block (static_block)
            .set_construct_block (instance_block)
            .add_method (default_ctor)
            .add_method (named_ctor)
            .add_method (destructor)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (widget_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
