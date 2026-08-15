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

public class NameAllocatorTest : Object {

    public static void main(string[] args) {
        Test.init (ref args);

        Test.add_func ("/valapoet/name_allocator",() => {
            var allocator = new NameAllocator ();
            assert_true (allocator.new_name ("class") == "@class");
            assert_true (allocator.new_name ("class") == "@class_2");
            assert_true (allocator.new_name ("signal") == "@signal");
            assert_true (allocator.new_name ("int") == "_int");
            assert_true (allocator.new_name ("foo") == "foo");
            assert_true (allocator.new_name ("foo") == "foo_2");
            assert_true (allocator.new_name ("123abc") == "_123abc");
        });

        Test.run ();
    }

}
