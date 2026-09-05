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

namespace ValaPoet {

    public class NameAllocator : GLib.Object {

        private GLib.List<string> allocated_names = new GLib.List<string>();
        private GLib.HashTable<Object, string> tag_to_name = new GLib.HashTable<Object, string> (direct_hash, direct_equal);

        private static string[] UNESCAPABLE_KEYWORDS = {
            "true", "false", "null", "bool", "char", "uchar", "double", "float",
            "int", "uint", "int8", "uint8", "int16", "uint16", "int32", "uint32",
            "int64", "uint64", "long", "ulong", "short", "ushort", "size_t", "ssize_t",
            "string", "void"
        };

        private static string[] ESCAPABLE_KEYWORDS = {
            "abstract", "as", "async", "base", "break", "case", "catch", "class",
            "const", "construct", "continue", "default", "delegate", "delete", "do",
            "dynamic", "else", "enum", "ensures", "extern", "finally", "for", "foreach",
            "get", "if", "in", "inline", "interface", "internal", "is", "lock", "namespace",
            "new", "out", "override", "owned", "params", "partial", "private", "protected",
            "public", "ref", "requires", "return", "sealed", "set", "signal", "sizeof",
            "static", "struct", "switch", "this", "throw", "throws", "try", "typeof",
            "unowned", "using", "var", "virtual", "volatile", "weak", "while", "yield"
        };

        public string new_name (string suggestion, Object? tag = null) {
            string sanitized = sanitize (suggestion);
            string name = sanitized;

            if (is_escapable_keyword (sanitized)) {
                name = "@" + sanitized;
                int index = 2;
                while (allocated_names.find_custom (name, strcmp) != null) {
                    name = "@" + sanitized + "_" + index.to_string ();
                    index++;
                }
            } else if (is_unescapable_keyword (sanitized)) {
                name = "_" + sanitized;
                int index = 2;
                while (allocated_names.find_custom (name, strcmp) != null) {
                    name = "_" + sanitized + "_" + index.to_string ();
                    index++;
                }
            } else {
                int index = 2;
                while (allocated_names.find_custom (name, strcmp) != null) {
                    name = sanitized + "_" + index.to_string ();
                    index++;
                }
            }

            allocated_names.append (name);
            if (tag != null) {
                tag_to_name.insert (tag, name);
            }
            return name;
        }

        public new string get (Object tag) {
            return tag_to_name.lookup (tag);
        }

        private static string sanitize (string suggestion) {
            var sb = new StringBuilder ();
            for (int i = 0; i < suggestion.length; i++) {
                unichar c = suggestion.get_char (i);
                if (c.isalnum () || c == '_') {
                    sb.append_unichar (c);
                } else {
                    sb.append_c ('_');
                }
            }
            string result = sb.str;
            if (result.length > 0 && result.get_char (0).isdigit ()) {
                result = "_" + result;
            }
            return (result.length > 0) ? result : "_";
        }

        private static bool is_escapable_keyword (string name) {
            return name in ESCAPABLE_KEYWORDS;
        }

        private static bool is_unescapable_keyword (string name) {
            return name in UNESCAPABLE_KEYWORDS;
        }

    }

}
