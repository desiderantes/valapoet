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

    public abstract class TypeName : GLib.Object {

        public unowned GLib.List<AttributeSpec> attributes { get; set; }

        public bool is_nullable { get; set; }
        public bool is_weak { get; set; }
        public bool is_unowned { get; set; }
        public bool is_owned { get; set; }

        public TypeName nullable () {
            var copy = this.copy ();
            copy.is_nullable = true;
            return copy;
        }

        public TypeName @weak () {
            var copy = this.copy ();
            copy.is_weak = true;
            return copy;
        }

        public TypeName @unowned () {
            var copy = this.copy ();
            copy.is_unowned = true;
            return copy;
        }

        public TypeName @owned () {
            var copy = this.copy ();
            copy.is_owned = true;
            return copy;
        }

        public PointerTypeName pointer_to () {
            return new PointerTypeName (this);
        }

        // Abstract methods to be implemented by subclasses
        public abstract string to_string ();
        public abstract TypeName copy ();

        private static TypeName? _object = null;
        public static TypeName OBJECT {
            get {
                if (_object == null) _object = new ClassName ("GLib", "Object");
                return _object;
            }
        }

        private static TypeName? _bool = null;
        public static TypeName BOOL {
            get {
                if (_bool == null) _bool = new PrimitiveTypeName ("bool");
                return _bool;
            }
        }

        private static TypeName? _short = null;
        public static TypeName SHORT {
            get {
                if (_short == null) _short = new PrimitiveTypeName ("short");
                return _short;
            }
        }

        private static TypeName? _int = null;
        public static TypeName INT {
            get {
                if (_int == null) _int = new PrimitiveTypeName ("int");
                return _int;
            }
        }

        private static TypeName? _long = null;
        public static TypeName LONG {
            get {
                if (_long == null) _long = new PrimitiveTypeName ("long");
                return _long;
            }
        }

        private static TypeName? _float = null;
        public static TypeName FLOAT {
            get {
                if (_float == null) _float = new PrimitiveTypeName ("float");
                return _float;
            }
        }

        private static TypeName? _double = null;
        public static TypeName DOUBLE {
            get {
                if (_double == null) _double = new PrimitiveTypeName ("double");
                return _double;
            }
        }

        private static TypeName? _char = null;
        public static TypeName CHAR {
            get {
                if (_char == null) _char = new PrimitiveTypeName ("char");
                return _char;
            }
        }

        private static TypeName? _unichar = null;
        public static TypeName UNICHAR {
            get {
                if (_unichar == null) _unichar = new PrimitiveTypeName ("unichar");
                return _unichar;
            }
        }

        private static TypeName? _string = null;
        public static TypeName STRING {
            get {
                if (_string == null) _string = new PrimitiveTypeName ("string");
                return _string;
            }
        }

        private static TypeName? _void = null;
        public static TypeName VOID {
            get {
                if (_void == null) _void = new PrimitiveTypeName ("void");
                return _void;
            }
        }

        private static TypeName? _string16 = null;
        public static TypeName STRING16 {
            get {
                if (_string16 == null) _string16 = new PrimitiveTypeName ("string16");
                return _string16;
            }
        }

        private static TypeName? _string32 = null;
        public static TypeName STRING32 {
            get {
                if (_string32 == null) _string32 = new PrimitiveTypeName ("string32");
                return _string32;
            }
        }

        private static TypeName? _uint8 = null;
        public static TypeName UINT8 {
            get {
                if (_uint8 == null) _uint8 = new PrimitiveTypeName ("uint8");
                return _uint8;
            }
        }

        private static TypeName? _uint16 = null;
        public static TypeName UINT16 {
            get {
                if (_uint16 == null) _uint16 = new PrimitiveTypeName ("uint16");
                return _uint16;
            }
        }

        private static TypeName? _uint32 = null;
        public static TypeName UINT32 {
            get {
                if (_uint32 == null) _uint32 = new PrimitiveTypeName ("uint32");
                return _uint32;
            }
        }

        private static TypeName? _uint64 = null;
        public static TypeName UINT64 {
            get {
                if (_uint64 == null) _uint64 = new PrimitiveTypeName ("uint64");
                return _uint64;
            }
        }

        private static TypeName? _int8 = null;
        public static TypeName INT8 {
            get {
                if (_int8 == null) _int8 = new PrimitiveTypeName ("int8");
                return _int8;
            }
        }

        private static TypeName? _int16 = null;
        public static TypeName INT16 {
            get {
                if (_int16 == null) _int16 = new PrimitiveTypeName ("int16");
                return _int16;
            }
        }

        private static TypeName? _int32 = null;
        public static TypeName INT32 {
            get {
                if (_int32 == null) _int32 = new PrimitiveTypeName ("int32");
                return _int32;
            }
        }

        private static TypeName? _int64 = null;
        public static TypeName INT64 {
            get {
                if (_int64 == null) _int64 = new PrimitiveTypeName ("int64");
                return _int64;
            }
        }

        private static TypeName? _ushort = null;
        public static TypeName USHORT {
            get {
                if (_ushort == null) _ushort = new PrimitiveTypeName ("ushort");
                return _ushort;
            }
        }

        private static TypeName? _uint = null;
        public static TypeName UINT {
            get {
                if (_uint == null) _uint = new PrimitiveTypeName ("uint");
                return _uint;
            }
        }

        private static TypeName? _ulong = null;
        public static TypeName ULONG {
            get {
                if (_ulong == null) _ulong = new PrimitiveTypeName ("ulong");
                return _ulong;
            }
        }

        private static TypeName? _uchar = null;
        public static TypeName UCHAR {
            get {
                if (_uchar == null) _uchar = new PrimitiveTypeName ("uchar");
                return _uchar;
            }
        }

        private static TypeName? _size_t = null;
        public static TypeName SIZE_T {
            get {
                if (_size_t == null) _size_t = new PrimitiveTypeName ("size_t");
                return _size_t;
            }
        }

        private static TypeName? _ssize_t = null;
        public static TypeName SSIZE_T {
            get {
                if (_ssize_t == null) _ssize_t = new PrimitiveTypeName ("ssize_t");
                return _ssize_t;
            }
        }

        private static TypeName? _unichar2 = null;
        public static TypeName UNICHAR2 {
            get {
                if (_unichar2 == null) _unichar2 = new PrimitiveTypeName ("unichar2");
                return _unichar2;
            }
        }
    }

    // Internal class for representing primitives
    internal class PrimitiveTypeName : TypeName {
        private string keyword;

        public PrimitiveTypeName (string keyword) {
            this.keyword = keyword;
            this.attributes = new GLib.List<AttributeSpec>();
        }

        public override string to_string () {
            return this.keyword;
        }

        public override TypeName copy () {
            var copy = new PrimitiveTypeName (this.keyword);
            copy.is_nullable = this.is_nullable;
            copy.is_weak = this.is_weak;
            copy.is_unowned = this.is_unowned;
            copy.is_owned = this.is_owned;
            return copy;
        }

    }

}
