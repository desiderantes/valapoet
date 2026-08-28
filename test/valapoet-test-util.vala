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

namespace ValaPoetTestUtil {

    public class CodeCompiler : GLib.Object {

        public static bool verify_code_compiles (string code_content, string[] extra_packages = {}) {
            string tmp_file = "tmp_compile_test_%u.vala".printf (Random.next_int ());
            try {
                FileUtils.set_contents (tmp_file, code_content);

                string[] argv = {
                    "valac",
                    "-C",
                    "--pkg", "gee-0.8",
                    "--pkg", "gio-2.0",
                    "--pkg", "gobject-2.0",
                    "--pkg", "glib-2.0"
                };

                foreach (var pkg in extra_packages) {
                    argv += "--pkg";
                    argv += pkg;
                }
                argv += tmp_file;

                int exit_status;
                string standard_output;
                string standard_error;

                Process.spawn_sync (null, argv, null, SpawnFlags.SEARCH_PATH, null, out standard_output, out standard_error, out exit_status);

                FileUtils.unlink (tmp_file);
                string c_file = tmp_file.replace (".vala", ".c");
                FileUtils.unlink (c_file);

                if (exit_status != 0) {
                    stderr.printf ("\n=== COMPILER VERIFICATION FAILED ===\n%s\n--- STDERR ---\n%s\n", code_content, standard_error);
                }

                return exit_status == 0;
            } catch (Error e) {
                stderr.printf ("Spawn error: %s\n", e.message);
                return false;
            }
        }

        public static bool verify_multiple_files_compile (string[] code_contents, string[] extra_packages = {}) {
            string[] tmp_files = {};
            string[] c_files = {};
            try {
                string[] argv = {
                    "valac",
                    "-C",
                    "--pkg", "gee-0.8",
                    "--pkg", "gio-2.0",
                    "--pkg", "gobject-2.0",
                    "--pkg", "glib-2.0"
                };

                foreach (var pkg in extra_packages) {
                    argv += "--pkg";
                    argv += pkg;
                }

                uint id = Random.next_int ();
                for (int i = 0; i < code_contents.length; i++) {
                    string tmp_file = "tmp_compile_test_%u_%d.vala".printf (id, i);
                    FileUtils.set_contents (tmp_file, code_contents[i]);
                    tmp_files += tmp_file;
                    c_files += tmp_file.replace (".vala", ".c");
                    argv += tmp_file;
                }

                int exit_status;
                string standard_output;
                string standard_error;

                Process.spawn_sync (null, argv, null, SpawnFlags.SEARCH_PATH, null, out standard_output, out standard_error, out exit_status);

                foreach (var f in tmp_files) {
                    FileUtils.unlink (f);
                }
                foreach (var f in c_files) {
                    FileUtils.unlink (f);
                }

                if (exit_status != 0) {
                    stderr.printf ("\n=== MULTI-FILE COMPILER VERIFICATION FAILED ===\n--- STDERR ---\n%s\n", standard_error);
                }

                return exit_status == 0;
            } catch (Error e) {
                stderr.printf ("Spawn error: %s\n", e.message);
                return false;
            }
        }

    }

}
