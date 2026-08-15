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

namespace ValaPoet.Utils {

    public static Gee.Set<T> set_of<T> (T[] args) {
        var retval = new Gee.HashSet<T>();
        retval.add_all_array (args);
        return retval;
    }

    public static Gee.Map<K, V> map_of<K, V> (Pair<K, V>[] pairs) {
        var retval = new Gee.HashMap<K, V>();
        foreach (var pair in pairs) {
            retval[pair.first] = pair.second;
        }
        return retval;
    }

    public static Gee.MultiMap<K, V> multimap_of<K, V> (Pair<K, Set<V> >[] pairs) {
        var retval = new Gee.HashMultiMap<K, V>();
        foreach (var pair in pairs) {
            foreach (var item in pair.second) {
                retval[pair.first] = item;
            }
        }
        return retval;
    }

    public class Pair<K, V> {
        public K first;
        public V second;

        public Pair (K first, V second) {
            this.first = first;
            this.second = second;
        }

    }
}
