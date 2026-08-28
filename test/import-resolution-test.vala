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

namespace ValaPoetTest {

    public class ImportResolutionTest : GLib.Object {

        public static int main (string[] args) {
            Test.init (ref args);

            Test.add_func ("/import-resolution/cross-namespace-multi-file", () => {
                test_cross_namespace_multi_file_import_resolution ();
            });

            Test.add_func ("/import-resolution/code-block-placeholder-type", () => {
                test_code_block_placeholder_type_import ();
            });

            Test.add_func ("/import-resolution/inheritance-and-interface", () => {
                test_inheritance_and_interface_import_resolution ();
            });

            Test.add_func ("/import-resolution/symbol-collision-canonical-disambiguation", () => {
                test_symbol_collision_canonical_disambiguation ();
            });

            return Test.run ();
        }

        private static void test_cross_namespace_multi_file_import_resolution () {
            // File 1: App.Models namespace defining User and UserRole
            var role_enum = EnumSpec.builder ("UserRole")
                .visibility (Visibility.PUBLIC)
                .add_constant ("ADMIN", 0)
                .add_constant ("MEMBER", 1)
                .build ();

            var user_class = TypeSpec.class_builder ("User")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_field (FieldSpec.builder (TypeName.STRING, "username").visibility (Visibility.PUBLIC).build ())
                .add_field (FieldSpec.builder (ClassName.get ("App.Models", "UserRole"), "role").visibility (Visibility.PUBLIC).build ())
                .build ();

            var file1 = ValaFile.builder ()
                .add_type (TypeSpec.namespace_builder ("App.Models")
                    .add_type (role_enum)
                    .add_type (user_class)
                    .build ()
                )
                .build ();

            // File 2: App.Services namespace referencing User and UserRole from App.Models
            var user_type = ClassName.get ("App.Models", "User");
            var role_type = ClassName.get ("App.Models", "UserRole");

            var get_role_method = MethodSpec.method_builder ("get_role")
                .visibility (Visibility.PUBLIC)
                .returns (role_type)
                .add_parameter (ParameterSpec.builder (user_type, "user").build ())
                .add_statement ("return user.role")
                .build ();

            var service_class = TypeSpec.class_builder ("UserService")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_method (get_role_method)
                .build ();

            var file2 = ValaFile.builder ()
                .add_type (TypeSpec.namespace_builder ("App.Services")
                    .add_type (service_class)
                    .build ()
                )
                .build ();

            string code1 = file1.to_string ();
            string code2 = file2.to_string ();

            // Assert that File 2 automatically resolved and emitted 'using App.Models;' header
            assert (code2.contains ("using App.Models;"));

            // Assert that both files compile cleanly together using valac
            string[] files = { code1, code2 };
            assert (CodeCompiler.verify_multiple_files_compile (files));
        }

        private static void test_code_block_placeholder_type_import () {
            var repo_type = ClassName.get ("Org.Database", "Repository");

            var init_code = CodeBlock.builder ()
                .add_statement ("var repo = new $T ()", repo_type)
                .add_statement ("repo.connect ()")
                .build ();

            var init_method = MethodSpec.method_builder ("init_database")
                .visibility (Visibility.PUBLIC)
                .add_code (init_code)
                .build ();

            var manager_class = TypeSpec.class_builder ("DbManager")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_method (init_method)
                .build ();

            var file = ValaFile.builder ()
                .add_type (TypeSpec.namespace_builder ("App.Core")
                    .add_type (manager_class)
                    .build ()
                )
                .build ();

            string code = file.to_string ();

            // Assert that referencing $T in a CodeBlock automatically emits 'using Org.Database;'
            assert (code.contains ("using Org.Database;"));
            assert (code.contains ("var repo = new Repository ();"));
        }

        private static void test_inheritance_and_interface_import_resolution () {
            var base_entity_type = ClassName.get ("App.Base", "Entity");
            var printable_interface_type = ClassName.get ("App.Contracts", "Printable");

            var print_method = MethodSpec.method_builder ("print")
                .visibility (Visibility.PUBLIC)
                .add_statement ("stdout.printf (\"Entity\\n\")")
                .build ();

            var item_class = TypeSpec.class_builder ("Item")
                .visibility (Visibility.PUBLIC)
                .superclass (base_entity_type)
                .add_superinterface (printable_interface_type)
                .add_method (print_method)
                .build ();

            var file = ValaFile.builder ()
                .add_type (TypeSpec.namespace_builder ("App.Domain")
                    .add_type (item_class)
                    .build ()
                )
                .build ();

            string code = file.to_string ();

            // Assert that superclass and superinterfaces automatically emit sorted usings
            assert (code.contains ("using App.Base;"));
            assert (code.contains ("using App.Contracts;"));
            assert (code.contains ("public class Item : Entity, Printable {"));
        }

        private static void test_symbol_collision_canonical_disambiguation () {
            // Parameter referencing external System.Diagnostics.Logger
            var ext_logger_type = ClassName.get ("System.Diagnostics", "Logger");

            var log_method = MethodSpec.method_builder ("attach_external_logger")
                .visibility (Visibility.PUBLIC)
                .add_parameter (ParameterSpec.builder (ext_logger_type, "ext_logger").build ())
                .add_statement ("stdout.printf (\"Attached\\n\")")
                .build ();

            // Class itself is named Logger inside App.Logging
            var logger_class = TypeSpec.class_builder ("Logger")
                .visibility (Visibility.PUBLIC)
                .superclass (TypeName.OBJECT)
                .add_method (log_method)
                .build ();

            var file = ValaFile.builder ()
                .add_type (TypeSpec.namespace_builder ("App.Logging")
                    .add_type (logger_class)
                    .build ()
                )
                .build ();

            string code = file.to_string ();

            // Because 'Logger' is an enclosing class name, the external Logger parameter must emit fully qualified as System.Diagnostics.Logger
            assert (code.contains ("System.Diagnostics.Logger ext_logger"));
        }

    }

}
