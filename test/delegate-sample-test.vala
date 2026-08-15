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

public class DelegateSampleTest : Object {

    public static void main(string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/delegate_sample",() => {
            var expected = """[CCode(has_target = false)]
delegate void CustomCallback (int status_code, string message);
""";
            var ccode_attr = AttributeSpec.builder ("CCode")
                              .add_argument ("has_target","false")
                              .build ();

            var delegate_spec = DelegateName.get ("CustomCallback",TypeName.VOID)
                                 .add_annotation (ccode_attr)
                                 .add_parameter (ParameterSpec.builder (TypeName.INT,"status_code").build ())
                                 .add_parameter (ParameterSpec.builder (TypeName.STRING,"message").build ());

            var vala_file = ValaFile.builder ()
                             .add_delegate (delegate_spec)
                             .build ();

            assert_true (vala_file.to_string () == expected);
            assert_true (ValaPoetTestUtil.CodeCompiler.verify_code_compiles (vala_file.to_string ()));
        });

        Test.run ();
    }

}
