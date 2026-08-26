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

public class ValaFileTest : Object {

    public static int main (string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/vala_file/using_deduplication_and_sorting", () => {
            var vala_file = ValaFile.builder ()
            .add_using ("Gee")
            .add_using ("GLib")
            .add_using ("Gee")
            .add_type (
                TypeSpec.class_builder ("MyClass")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .build ()
            )
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("using Gee;\n"));
            assert_true (code.contains ("using GLib;\n"));
            assert_true (CodeCompiler.verify_code_compiles (code, { "gee-0.8" }));
        });

        Test.add_func ("/valapoet/vala_file/namespace_wrapping", () => {
            var service_class = TypeSpec.class_builder ("Service")
            .visibility (Visibility.PUBLIC)
            .superclass (TypeName.OBJECT)
            .build ();

            var ns = TypeSpec.namespace_builder ("Org.Example.App")
            .add_type (service_class)
            .build ();

            var vala_file = ValaFile.builder ()
            .set_namespace (ns)
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("namespace Org.Example.App {\n"));
            assert_true (code.contains ("\tpublic class Service : GLib.Object {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        Test.add_func ("/valapoet/vala_file/indentation", () => {
            var vala_file = ValaFile.builder ()
            .indent ("    ")
            .add_type (
                TypeSpec.class_builder ("CustomIndentClass")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .build ()
            )
            .build ();

            string code = vala_file.to_string ();
            assert_true (code.contains ("public class CustomIndentClass : GLib.Object {\n"));
            assert_true (CodeCompiler.verify_code_compiles (code));
        });

        return Test.run ();
    }

}
