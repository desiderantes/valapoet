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

public class AsyncMethodSampleTest : Object {

    public static void main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/async_method_sample", () => {
            var expected = """public class NetworkClient : GLib.Object {
	public unowned string get_endpoint () {
		return "https://example.com";
	}

	private async void fetch_internal () throws GLib.FileError, GLib.IOError {
	}

	public async void fetch_data_async () throws GLib.FileError, GLib.IOError {
		yield fetch_internal ();
	}
}
""";
            var get_endpoint = MethodSpec.method_builder ("get_endpoint")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING.copy ().@unowned ())
            .add_statement ("return \"https://example.com\"")
            .build ();

            var fetch_internal = MethodSpec.method_builder ("fetch_internal")
            .visibility (Visibility.PRIVATE).add_modifiers (SymbolModifier.ASYNC)
            .add_throws (ClassName.get ("GLib", "FileError"))
            .add_throws (ClassName.get ("GLib", "IOError"))
            .build ();

            var fetch_data = MethodSpec.method_builder ("fetch_data_async")
            .visibility (Visibility.PUBLIC).add_modifiers (SymbolModifier.ASYNC)
            .add_throws (ClassName.get ("GLib", "FileError"))
            .add_throws (ClassName.get ("GLib", "IOError"))
            .add_statement ("yield fetch_internal ()")
            .build ();

            var client_class = TypeSpec.class_builder ("NetworkClient")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .add_method (get_endpoint)
            .add_method (fetch_internal)
            .add_method (fetch_data)
            .build ();

            var vala_file = ValaFile.builder ()
            .add_type (client_class)
            .build ();

            assert_cmpstr (vala_file.to_string (), GLib.CompareOperator.EQ, expected);
            assert_true (CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
