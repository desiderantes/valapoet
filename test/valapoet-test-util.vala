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

namespace ValaPoetTestUtil {

    public class CodeCompiler : GLib.Object {

        public static bool verify_code_compiles(string code_content,string[] extra_packages = {}) {
            string tmp_file = "tmp_compile_test_%u.vala".printf (Random.next_int ());
            try {
                FileUtils.set_contents (tmp_file,code_content);

                var cmd = new Gee.ArrayList<string>();
                cmd.add ("valac");
                cmd.add ("-C");
                cmd.add ("--pkg");
                cmd.add ("gee-0.8");
                cmd.add ("--pkg");
                cmd.add ("gio-2.0");
                cmd.add ("--pkg");
                cmd.add ("gobject-2.0");
                cmd.add ("--pkg");
                cmd.add ("glib-2.0");

                foreach (var pkg in extra_packages) {
                    cmd.add ("--pkg");
                    cmd.add (pkg);
                }
                cmd.add (tmp_file);

                string[] argv = new string[cmd.size];
                for (int i = 0 ; i < cmd.size ; i++) {
                    argv[i] = cmd[i];
                }

                int exit_status;
                string standard_output;
                string standard_error;

                Process.spawn_sync (null,argv,null,SpawnFlags.SEARCH_PATH,null,out standard_output,out standard_error,out exit_status);

                FileUtils.unlink (tmp_file);
                string c_file = tmp_file.replace (".vala",".c");
                FileUtils.unlink (c_file);

                if (exit_status != 0) {
                    stderr.printf ("\n=== COMPILER VERIFICATION FAILED ===\n%s\n--- STDERR ---\n%s\n",code_content,standard_error);
                }

                return exit_status == 0;
            } catch (Error e) {
                stderr.printf ("Spawn error: %s\n",e.message);
                return false;
            }
        }

    }

}
