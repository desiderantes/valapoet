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

public class SignalSampleTest : Object {

    public static void main(string[] args) {
        Test.init (ref args);
        Test.add_func ("/valapoet/signal_sample",() => {
            var expected_output = """class Foo {
	public signal void some_event (int i);
}

class Demo {
	static void on_some_event (Foo sender, int i) {
		stdout.printf ("Handler A: %d\n", i);
	}

	static void main () {
		var foo = new Foo ();
		foo.some_event.connect (on_some_event);
		foo.some_event.connect ((s, i) => stdout.printf ("Handler B: %d\n", i));
		foo.some_event (42);
		foo.some_event.disconnect (on_some_event);
	}
}
""";

            var some_event_signal = SignalSpec.builder ("some_event")
                                     .add_modifiers (ValaModifier.PUBLIC)
                                     .add_parameter (ParameterSpec.builder (TypeName.INT,"i").build ())
                                     .build ();

            var foo_class = TypeSpec.class_builder ("Foo")
                             .add_signal (some_event_signal)
                             .build ();

            var on_some_event_method = MethodSpec.method_builder ("on_some_event")
                                        .add_modifiers (ValaModifier.STATIC)
                                        .add_parameter (ParameterSpec.builder (ClassName.get ("","Foo"),"sender").build ())
                                        .add_parameter (ParameterSpec.builder (TypeName.INT,"i").build ())
                                        .add_statement ("stdout.printf (\"Handler A: %d\\n\", i)")
                                        .build ();

            var main_method = MethodSpec.method_builder ("main")
                               .add_modifiers (ValaModifier.STATIC)
                               .add_statement ("var foo = new Foo ()")
                               .add_statement ("foo.some_event.connect (on_some_event)")
                               .add_statement ("foo.some_event.connect ((s, i) => stdout.printf (\"Handler B: %d\\n\", i))")
                               .add_statement ("foo.some_event (42)")
                               .add_statement ("foo.some_event.disconnect (on_some_event)")
                               .build ();

            var demo_class = TypeSpec.class_builder ("Demo")
                              .add_method (on_some_event_method)
                              .add_method (main_method)
                              .build ();

            var vala_file = ValaFile.builder ()
                             .add_type (foo_class)
                             .add_type (demo_class)
                             .build ();

            assert_true (vala_file.to_string () == expected_output);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });
        Test.run ();
    }

}
