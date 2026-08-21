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

public class DBusSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/dbus_sample", () => {
            var expected = """[DBus(name = "org.example.DemoService")]
public class DemoService : GLib.Object {
	public signal void status_changed (string status);
	public int counter {
		get; set;
	}
	public void execute_action (string action_name) {
		counter++;
		status_changed (action_name);
	}
}
""";
            var dbus_attr = AttributeSpec.builder ("DBus")
            .add_argument ("name", "\"org.example.DemoService\"")
            .build ();

            var status_signal = SignalSpec.builder ("status_changed")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "status").build ())
            .build ();

            var counter_prop = PropertySpec.builder (TypeName.INT, "counter")
            .visibility (Visibility.PUBLIC)
            .auto ()
            .build ();

            var exec_method = MethodSpec.method_builder ("execute_action")
            .visibility (Visibility.PUBLIC)
            .add_parameter (ParameterSpec.builder (TypeName.STRING, "action_name").build ())
            .add_statement ("counter++")
            .add_statement ("status_changed (action_name)")
            .build ();

            var service_class = TypeSpec.class_builder ("DemoService")
            .add_attribute (dbus_attr)
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_signal (status_signal)
            .add_property (counter_prop)
            .add_method (exec_method)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (service_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string (), { "gio-2.0" }));
        });

        Test.run ();
    }

}
