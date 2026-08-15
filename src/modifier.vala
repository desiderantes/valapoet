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

using Gee;
using ValaPoet.Utils;

namespace ValaPoet {
    public enum Modifier {
        PRIVATE,
        PUBLIC,
        PROTECTED,
        INTERNAL,
        SEALED,

        OUT,
        REF,

        CONST,
        OWNED,
        UNOWNED,
        WEAK,

        ABSTRACT,
        VIRTUAL,
        OVERRIDE,
        EXTERN,
        STATIC,
        ASYNC,
        INLINE,
        NEW,

        CONSTRUCT,

        NULLABLE;

        public bool applies_to(Target target) {
            return ModifierCompanion.target_map[this].contains (target);
        }

        public Set<Target> get_targets() {
            return ModifierCompanion.target_map[this].read_only_view;
        }

        public Set<Modifier> get_visibility_modifiers() {
            return ModifierCompanion.VISIBILITY_MODIFIERS;
        }

        public string to_string() {
            switch (this) {
            case PRIVATE:
                return "private";
            case PUBLIC:
                return "public";
            case PROTECTED:
                return "protected";
            case INTERNAL:
                return "internal";
            case SEALED:
                return "sealed";

            case OUT:
                return "out";
            case REF:
                return "ref";

            case CONST:
                return "const";
            case OWNED:
                return "owned";
            case UNOWNED:
                return "unowned";
            case WEAK:
                return "weak";

            case ABSTRACT:
                return "abstract";
            case VIRTUAL:
                return "virtual";
            case OVERRIDE:
                return "override";
            case EXTERN:
                return "extern";
            case STATIC:
                return "static";
            case ASYNC:
                return "async";
            case INLINE:
                return "inline";
            case NEW:
                return "new";

            case CONSTRUCT:
                return "construct";

            case NULLABLE:
                return "?";
            default:
                assert_not_reached ();
            }
        }

    }

    public enum Target {
        ENUM,
        SIGNAL,
        ERRORDOMAIN,
        STRUCT,
        DELEGATE,
        CLASS,
        METHOD,
        PROPERTY,
        PARAMETER,
        FIELD,
        TYPE,
        GETTER_SETTER
    }

    internal class ModifierCompanion{
        internal static Gee.Map<Modifier,Set<Target> > target_map = Utils.map_of<Modifier,Set<Target> >({
            new Pair<Modifier,Set<Target> >(Modifier.PRIVATE,Utils.set_of<Target>({
                Target.CLASS,Target.ENUM,Target.SIGNAL,Target.ERRORDOMAIN,Target.STRUCT,Target.DELEGATE,
                Target.METHOD,Target.PROPERTY,Target.FIELD,Target.GETTER_SETTER
            })),
            new Pair<Modifier,Set<Target> >(Modifier.PUBLIC,Utils.set_of<Target>({
                Target.CLASS,Target.ENUM,Target.SIGNAL,Target.ERRORDOMAIN,Target.STRUCT,Target.DELEGATE,
                Target.METHOD,Target.PROPERTY,Target.FIELD,Target.GETTER_SETTER
            })),
            new Pair<Modifier,Set<Target> >(Modifier.PROTECTED,Utils.set_of<Target>({
                Target.CLASS,Target.ENUM,Target.SIGNAL,Target.ERRORDOMAIN,Target.STRUCT,Target.DELEGATE,
                Target.METHOD,Target.PROPERTY,Target.FIELD,Target.GETTER_SETTER
            })),
            new Pair<Modifier,Set<Target> >(Modifier.INTERNAL,Utils.set_of<Target>({
                Target.CLASS,Target.ENUM,Target.SIGNAL,Target.ERRORDOMAIN,Target.STRUCT,Target.DELEGATE,
                Target.METHOD,Target.PROPERTY,Target.FIELD
            })),
            new Pair<Modifier,Set<Target> >(Modifier.SEALED,Utils.set_of<Target>({ Target.CLASS })),

            new Pair<Modifier,Set<Target> >(Modifier.OUT,Utils.set_of<Target>({ Target.PARAMETER,Target.TYPE })),
            new Pair<Modifier,Set<Target> >(Modifier.REF,Utils.set_of<Target>({ Target.PARAMETER,Target.TYPE })),

            new Pair<Modifier,Set<Target> >(Modifier.CONST,Utils.set_of<Target>({ Target.METHOD,Target.DELEGATE,Target.FIELD })),
            new Pair<Modifier,Set<Target> >(Modifier.OWNED,Utils.set_of<Target>({ Target.PARAMETER,Target.FIELD })),
            new Pair<Modifier,Set<Target> >(Modifier.UNOWNED,Utils.set_of<Target>({ Target.PARAMETER,Target.FIELD })),
            new Pair<Modifier,Set<Target> >(Modifier.WEAK,Utils.set_of<Target>({ Target.PARAMETER,Target.FIELD })),

            new Pair<Modifier,Set<Target> >(Modifier.ABSTRACT,Utils.set_of<Target>({ Target.CLASS,Target.METHOD })),
            new Pair<Modifier,Set<Target> >(Modifier.VIRTUAL,Utils.set_of<Target>({ Target.METHOD })),
            new Pair<Modifier,Set<Target> >(Modifier.OVERRIDE,Utils.set_of<Target>({ Target.METHOD })),
            new Pair<Modifier,Set<Target> >(Modifier.EXTERN,Utils.set_of<Target>({ Target.METHOD,Target.DELEGATE,Target.FIELD })),
            new Pair<Modifier,Set<Target> >(Modifier.STATIC,Utils.set_of<Target>({ Target.METHOD,Target.DELEGATE,Target.FIELD })),
            new Pair<Modifier,Set<Target> >(Modifier.ASYNC,Utils.set_of<Target>({ Target.METHOD,Target.DELEGATE })),
            new Pair<Modifier,Set<Target> >(Modifier.INLINE,Utils.set_of<Target>({ Target.METHOD })),
            new Pair<Modifier,Set<Target> >(Modifier.NEW,Utils.set_of<Target>({ Target.METHOD })),

            new Pair<Modifier,Set<Target> >(Modifier.CONSTRUCT,Utils.set_of<Target>({ Target.GETTER_SETTER })),

            new Pair<Modifier,Set<Target> >(Modifier.NULLABLE,Utils.set_of<Target>({ Target.TYPE }))
        }).read_only_view;

        public static Set<Modifier> VISIBILITY_MODIFIERS = Utils.set_of<Modifier>({ Modifier.PUBLIC,Modifier.INTERNAL,Modifier.PROTECTED,Modifier.PRIVATE }).read_only_view;
    }
}
