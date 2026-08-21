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

    public enum Target {
        CLASS,
        STRUCT,
        INTERFACE,
        METHOD,
        PROPERTY,
        FIELD,
        SIGNAL,
        DELEGATE,
        ENUM,
        CONSTRUCT
    }

    public enum Visibility {
        NONE,
        PUBLIC,
        PRIVATE,
        PROTECTED,
        INTERNAL;

        public string to_string () {
            switch (this) {
            case PUBLIC:
                return "public";
            case PRIVATE:
                return "private";
            case PROTECTED:
                return "protected";
            case INTERNAL:
                return "internal";
            default:
                return "";
            }
        }
    }

    public enum SymbolModifier {
        NONE,
        STATIC,
        ABSTRACT,
        VIRTUAL,
        OVERRIDE,
        SEALED,
        EXTERN,
        INLINE,
        ASYNC,
        NEW,
        CONST;

        public bool applies_to (Target target) {
            switch (this) {
            case ABSTRACT:
                return target == Target.CLASS || target == Target.INTERFACE || target == Target.METHOD || target == Target.PROPERTY;
            case VIRTUAL:
            case OVERRIDE:
                return target == Target.METHOD || target == Target.PROPERTY;
            case STATIC:
                return target == Target.CLASS || target == Target.METHOD || target == Target.FIELD || target == Target.PROPERTY || target == Target.CONSTRUCT;
            case SEALED:
                return target == Target.CLASS;
            case ASYNC:
                return target == Target.METHOD || target == Target.DELEGATE;
            case INLINE:
                return target == Target.METHOD;
            case EXTERN:
                return target == Target.METHOD || target == Target.FIELD || target == Target.DELEGATE;
            case CONST:
                return target == Target.METHOD || target == Target.FIELD;
            case NEW:
                return target == Target.METHOD || target == Target.PROPERTY || target == Target.FIELD;
            default:
                return false;
            }
        }

        public bool targets_method () {
            return applies_to (Target.METHOD);
        }

        public bool targets_class () {
            return applies_to (Target.CLASS);
        }

        public bool targets_interface () {
            return applies_to (Target.INTERFACE);
        }

        public bool targets_property () {
            return applies_to (Target.PROPERTY);
        }

        public bool targets_field () {
            return applies_to (Target.FIELD);
        }

        public bool targets_signal () {
            return applies_to (Target.SIGNAL);
        }

        public bool targets_delegate () {
            return applies_to (Target.DELEGATE);
        }

        public string to_string () {
            switch (this) {
            case STATIC:
                return "static";
            case ABSTRACT:
                return "abstract";
            case VIRTUAL:
                return "virtual";
            case OVERRIDE:
                return "override";
            case SEALED:
                return "sealed";
            case EXTERN:
                return "extern";
            case INLINE:
                return "inline";
            case ASYNC:
                return "async";
            case NEW:
                return "new";
            case CONST:
                return "const";
            default:
                return "";
            }
        }
    }

    public enum Ownership {
        NONE,
        OWNED,
        UNOWNED,
        WEAK;

        public string to_string () {
            switch (this) {
            case OWNED:
                return "owned";
            case UNOWNED:
                return "unowned";
            case WEAK:
                return "weak";
            default:
                return "";
            }
        }
    }

    public enum ParameterDirection {
        IN,
        OUT,
        REF;

        public string to_string () {
            switch (this) {
            case OUT:
                return "out";
            case REF:
                return "ref";
            default:
                return "";
            }
        }
    }

}
