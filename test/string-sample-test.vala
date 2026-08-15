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

public class StringSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/string_sample", () => {
            var expected_output = """void println (string str) {
	stdout.printf ("%s\n", str);
}

void main () {
	string a = "Concatenated ";
	string b = "string";
	string c = a + b;
	println (c);
	var builder = new StringBuilder ();
	builder.append ("built ");
	builder.prepend ("String ");
	builder.append ("StringBuilder");
	builder.append_unichar ('.');
	builder.insert (13, "by ");
	println (builder.str);
	string formatted = "PI %s equals %g.".printf ("approximately", Math.PI);
	println (formatted);
	string name = "Dave";
	println (@"Good morning, $name!");
	println (@"4 + 3 = $(4 + 3)");
	a = "foo";
	b = "foo";
	if (a == b) {
		println ("String == operator compares content, not reference.");
	} else {
		assert_not_reached ();
	}
	if ("blue" < "red" && "orange" > "green") {
		println ("blue is less than red and orange is greater than green");
	}
	string pl = "vala";
	switch (pl) {
		case "java":
			assert_not_reached ();
		case "vala":
			println ("Switch statement works fine with strings.");
			break;
		case "ruby":
			assert_not_reached ();
	}
	println ("from lower case to upper case".up ());
	println ("reversed string".reverse ());
	println ("...substring...".substring (3, 9));
	if ("word" in "swordfish") {
		println ("word is a part of swordfish");
	}
	try {
		var regex = new Regex ("(jaguar|tiger|leopard)");
		string animals = "wolf, tiger, eagle, jaguar, leopard, bear";
		println (regex.replace (animals, -1, 0, "kitty"));
	} catch (RegexError e) {
		warning ("%s", e.message);
	}
}
""";
            var println_method = MethodSpec.method_builder ("println")
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "str").build ())
            .add_statement ("stdout.printf (\"%s\\n\", str)")
            .build ();

            var main_method = MethodSpec.method_builder ("main")
            .add_statement ("string a = \"Concatenated \"")
            .add_statement ("string b = \"string\"")
            .add_statement ("string c = a + b")
            .add_statement ("println (c)")
            .add_statement ("var builder = new StringBuilder ()")
            .add_statement ("builder.append (\"built \")")
            .add_statement ("builder.prepend (\"String \")")
            .add_statement ("builder.append (\"StringBuilder\")")
            .add_statement ("builder.append_unichar ('.')")
            .add_statement ("builder.insert (13, \"by \")")
            .add_statement ("println (builder.str)")
            .add_statement ("string formatted = \"PI %s equals %g.\".printf (\"approximately\", Math.PI)")
            .add_statement ("println (formatted)")
            .add_statement ("string name = \"Dave\"")
            .add_statement ("println (@\"Good morning, $$name!\")")
            .add_statement ("println (@\"4 + 3 = $$(4 + 3)\")")
            .add_statement ("a = \"foo\"")
            .add_statement ("b = \"foo\"")
            .begin_control_flow ("if (a == b)")
            .add_statement ("println (\"String == operator compares content, not reference.\")")
            .next_control_flow ("else")
            .add_statement ("assert_not_reached ()")
            .end_control_flow ()
            .begin_control_flow ("if (\"blue\" < \"red\" && \"orange\" > \"green\")")
            .add_statement ("println (\"blue is less than red and orange is greater than green\")")
            .end_control_flow ()
            .add_statement ("string pl = \"vala\"")
            .begin_control_flow ("switch (pl)")
            .add_statement ("case \"java\":")
            .indent ()
            .add_statement ("assert_not_reached ()")
            .unindent ()
            .add_statement ("case \"vala\":")
            .indent ()
            .add_statement ("println (\"Switch statement works fine with strings.\")")
            .add_statement ("break")
            .unindent ()
            .add_statement ("case \"ruby\":")
            .indent ()
            .add_statement ("assert_not_reached ()")
            .unindent ()
            .end_control_flow ()
            .add_statement ("println (\"from lower case to upper case\".up ())")
            .add_statement ("println (\"reversed string\".reverse ())")
            .add_statement ("println (\"...substring...\".substring (3, 9))")
            .begin_control_flow ("if (\"word\" in \"swordfish\")")
            .add_statement ("println (\"word is a part of swordfish\")")
            .end_control_flow ()
            .begin_control_flow ("try")
            .add_statement ("var regex = new Regex (\"(jaguar|tiger|leopard)\")")
            .add_statement ("string animals = \"wolf, tiger, eagle, jaguar, leopard, bear\"")
            .add_statement ("println (regex.replace (animals, -1, 0, \"kitty\"))")
            .next_control_flow ("catch (RegexError e)")
            .add_statement ("warning (\"%s\", e.message)")
            .end_control_flow ()
            .build ();

            var vala_file = ValaFile.builder ()
            .add_method (println_method)
            .add_method (main_method)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected_output);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.add_func ("/valapoet/raw_statement_literals", () => {
            var print_method = MethodSpec.method_builder ("print_format")
            .add_modifiers (ValaModifier.PUBLIC)
            .add_statement_raw ("string text = \"%s = %d\".printf (\"item\", 42)")
            .add_statement_raw ("stdout.printf (\"%s\\n\", text)")
            .build ();

            var test_class = TypeSpec.class_builder ("RawLiteralDemo")
            .add_modifiers (ValaModifier.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (print_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (test_class)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("string text = \"%s = %d\".printf (\"item\", 42);"));
            assert_true (code.contains ("stdout.printf (\"%s\\n\", text);"));
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (code));
        });

        Test.run ();
    }

}
