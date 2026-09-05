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

    public class ValadocSpec : GLib.Object {

        public class ParamDoc : GLib.Object {
            public string name { get; private set; }
            public string description { get; private set; }

            public ParamDoc (string name, string description) {
                this.name = name;
                this.description = description;
            }
        }

        public class ThrowsDoc : GLib.Object {
            public string error_domain { get; private set; }
            public string description { get; private set; }

            public ThrowsDoc (string error_domain, string description) {
                this.error_domain = error_domain;
                this.description = description;
            }
        }

        public bool inherit_doc { get; private set; }
        public string? summary { get; private set; }
        public string? description { get; private set; }

        private GLib.List<ParamDoc> _params_docs;
        public unowned GLib.List<ParamDoc> params_docs {
            get { return _params_docs; }
        }

        public string? returns_doc { get; private set; }

        private GLib.List<ThrowsDoc> _throws_docs;
        public unowned GLib.List<ThrowsDoc> throws_docs {
            get { return _throws_docs; }
        }

        public string? since_version { get; private set; }
        public string? deprecated_reason { get; private set; }

        private GLib.List<string> _see_also;
        public unowned GLib.List<string> see_also {
            get { return _see_also; }
        }

        public static string link (string symbol_name) {
            return "{@link %s}".printf (symbol_name);
        }

        private ValadocSpec (Builder builder) {
            this.inherit_doc = builder.inherit_doc_flag;
            this.summary = builder.summary_text;
            this.description = builder.description_text;
            this.returns_doc = builder.returns_text;
            this.since_version = builder.since_text;
            this.deprecated_reason = builder.deprecated_text;

            this._params_docs = builder.params_docs.copy_deep ((CopyFunc) Object.ref);
            this._throws_docs = builder.throws_docs.copy_deep ((CopyFunc) Object.ref);
            this._see_also = builder.see_also.copy_deep ((CopyFunc) strdup);
        }

        public CodeBlock to_code_block () {
            var builder = new CodeBlock.Builder ();

            if (inherit_doc) {
                builder.add_raw ("{@inheritDoc}\n");
            }

            if (summary != null) {
                builder.add_raw (summary + "\n");
            }

            if (description != null) {
                if (summary != null || inherit_doc) {
                    builder.add_raw ("\n");
                }
                foreach (var line in description.split ("\n")) {
                    builder.add_raw (line + "\n");
                }
            }

            bool has_tags = (params_docs != null && params_docs.length () > 0)
                         || returns_doc != null
                         || (throws_docs != null && throws_docs.length () > 0)
                         || since_version != null
                         || deprecated_reason != null
                         || (see_also != null && see_also.length () > 0);

            if (has_tags && (summary != null || description != null || inherit_doc)) {
                builder.add_raw ("\n");
            }

            if (params_docs != null) {
                foreach (var p in params_docs) {
                    builder.add_raw ("@param " + p.name + " " + p.description + "\n");
                }
            }

            if (returns_doc != null) {
                builder.add_raw ("@return " + returns_doc + "\n");
            }

            if (throws_docs != null) {
                foreach (var t in throws_docs) {
                    builder.add_raw ("@throws " + t.error_domain + " " + t.description + "\n");
                }
            }

            if (since_version != null) {
                builder.add_raw ("@since " + since_version + "\n");
            }

            if (deprecated_reason != null) {
                builder.add_raw ("@deprecated " + deprecated_reason + "\n");
            }

            if (see_also != null) {
                foreach (var s in see_also) {
                    builder.add_raw ("@see " + s + "\n");
                }
            }

            return builder.build ();
        }

        public static Builder builder () {
            return new Builder ();
        }

        public class Builder : GLib.Object {
            public bool inherit_doc_flag { get; private set; }
            public string? summary_text { get; private set; }
            public string? description_text { get; private set; }

            private GLib.List<ParamDoc> _params_docs;
            public unowned GLib.List<ParamDoc> params_docs {
                get { return _params_docs; }
            }

            public string? returns_text { get; private set; }

            private GLib.List<ThrowsDoc> _throws_docs;
            public unowned GLib.List<ThrowsDoc> throws_docs {
                get { return _throws_docs; }
            }

            public string? since_text { get; private set; }
            public string? deprecated_text { get; private set; }

            private GLib.List<string> _see_also;
            public unowned GLib.List<string> see_also {
                get { return _see_also; }
            }

            public Builder () {
                this.inherit_doc_flag = false;
                this._params_docs = new GLib.List<ParamDoc>();
                this._throws_docs = new GLib.List<ThrowsDoc>();
                this._see_also = new GLib.List<string>();
            }

            public Builder inherit_doc (bool inherit = true) {
                this.inherit_doc_flag = inherit;
                return this;
            }

            public Builder summary (string summary) {
                this.summary_text = summary;
                return this;
            }

            public Builder description (string description) {
                this.description_text = description;
                return this;
            }

            public Builder add_param (string name, string description) {
                this._params_docs.append (new ParamDoc (name, description));
                return this;
            }

            public Builder returns (string description) {
                this.returns_text = description;
                return this;
            }

            public Builder @throws (string error_domain, string description) {
                this._throws_docs.append (new ThrowsDoc (error_domain, description));
                return this;
            }

            public Builder since (string version) {
                this.since_text = version;
                return this;
            }

            public Builder deprecated (string reason) {
                this.deprecated_text = reason;
                return this;
            }

            public Builder see (string reference) {
                this._see_also.append (reference);
                return this;
            }

            public ValadocSpec build () {
                return new ValadocSpec (this);
            }
        }
    }

}
