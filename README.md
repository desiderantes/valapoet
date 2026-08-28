# ValaPoet

`ValaPoet` is a Vala library for generating `.vala` source files, inspired by [JavaPoet](https://github.com/square/javapoet).

It provides fluent builder APIs to generate robust, idiomatic Vala code programmatically—complete with automatic `using` directive resolution, memory ownership annotations (`owned`, `unowned`, `weak`), GObject properties and signals, async methods, contract programming (`requires`/`ensures`), enums with methods, error domains, delegates, non-docstring single-line comments (`//`), ValaDoc docstrings, and keyword-safe identifier allocation.

---

## Dependencies

### Library (`libvalapoet`)
`ValaPoet` has zero third-party library dependencies and relies exclusively on standard GLib core libraries:
* **GLib** (`>= 2.80`)
* **GObject** (`>= 2.80`)
* **Gio** (`>= 2.80`)

### Test Suite (`test/`)
Running the test suite (`meson test`) requires:
* **Vala Compiler** (`>= 0.56`)
* **Libgee** (`gee-0.8`) *(test suite only)*

---

## Quick Example

Here is how you generate a standard Vala `HelloWorld` program:

```vala
var main_method = MethodSpec.method_builder ("main")
    .add_comment ("Entry point of the application")
    .visibility (Visibility.PUBLIC)
    .add_modifiers (SymbolModifier.STATIC)
    .returns (TypeName.INT)
    .add_parameter (ParameterSpec.builder (new ArrayTypeName (TypeName.STRING), "args").build ())
    .add_statement ("stdout.printf (\"Hello, ValaPoet!\\n\")")
    .add_statement ("return 0")
    .build ();

var hello_world_class = TypeSpec.class_builder ("HelloWorld")
    .add_comment ("Main application class")
    .visibility (Visibility.PUBLIC)
    .superclass (TypeName.OBJECT)
    .add_method (main_method)
    .build ();

var vala_file = ValaFile.builder ()
    .add_type (TypeSpec.namespace_builder ("Example")
        .add_type (hello_world_class)
        .build ()
    )
    .build ();

print ("%s", vala_file.to_string ());
```

**Generates:**

```vala
namespace Example {

	// Main application class
	public class HelloWorld : GLib.Object {
		// Entry point of the application
		public static int main (string[] args) {
			stdout.printf ("Hello, ValaPoet!\n");
			return 0;
		}
	}
}
```

---

## Code & Control Flow

Method bodies are built using fluent control-flow methods on `MethodSpec.Builder` or `CodeBlock.Builder`:

```vala
var main_method = MethodSpec.method_builder ("main")
    .add_statement ("int total = 0")
    .begin_control_flow ("for (int i = 0; i < 10; i++)")
    .add_statement ("total += i")
    .end_control_flow ()
    .build ();
```

**Generates:**

```vala
void main () {
	int total = 0;
	for (int i = 0; i < 10; i++) {
		total += i;
	}
}
```

---

## Placeholders in `CodeBlock`

`CodeBlock` formats code strings using JavaPoet-style placeholders:

- `$S` for **Strings**: Formats and escapes string literals with quotes (`"hello"`).
- `$T` for **Types**: Emits type names and registers target namespaces for automatic `using` imports.
- `$N` for **Names**: Emits the declared name of another spec object (`TypeSpec`, `MethodSpec`, `FieldSpec`, `PropertySpec`, `ParameterSpec`).
- `$L` for **Literals**: Emits literal values without modification.
- `$>` / `$<`: Increases or decreases code block indentation.

```vala
var list_type = new ParameterizedTypeName (
    ClassName.get ("Gee", "ArrayList"),
    TypeName.STRING
);

var code = CodeBlock.builder ()
    .add_statement ("var list = new $T ()", list_type)
    .add_statement ("list.add ($S)", "ValaPoet")
    .build ();
```

---

## Vala Language Features

### 1. Enums with Constants, Custom Values & Methods
Define enums, customize integer values, add single-line comments, and attach instance or static methods:

```vala
var status_enum = EnumSpec.builder ("Status")
    .visibility (Visibility.PUBLIC)
    .add_comment ("System operational status")
    .add_constant ("IDLE", 0)
    .add_constant ("RUNNING", 1)
    .add_constant ("FINISHED", 2)
    .add_method (
        MethodSpec.method_builder ("to_display_string")
            .visibility (Visibility.PUBLIC)
            .returns (TypeName.STRING)
            .begin_switch ("this")
                .add_statement ("case IDLE: return \"Idle\"")
                .add_statement ("case RUNNING: return \"Running\"")
                .add_statement ("case FINISHED: return \"Finished\"")
                .add_statement ("default: return \"Unknown\"")
            .end_control_flow ()
            .build ()
    )
    .build ();
```

**Generates:**

```vala
// System operational status
public enum Status {
	IDLE = 0,
	RUNNING = 1,
	FINISHED = 2;

	public string to_display_string () {
		switch (this) {
			case IDLE: return "Idle";
			case RUNNING: return "Running";
			case FINISHED: return "Finished";
			default: return "Unknown";
		}
	}
}
```

---

### 2. Symbol Comments (`//`) vs ValaDoc Docstrings (`/** ... */`)
ValaPoet clearly separates single-line code comments (`// ...`) from ValaDoc documentation (`/** ... */`):

```vala
var field = FieldSpec.builder (TypeName.INT, "counter")
    .add_comment ("Internal state counter") // Emits: // Internal state counter
    .add_valadoc ("Value representing item count.") // Emits: /** * Value representing item count. */
    .visibility (Visibility.PRIVATE)
    .build ();
```

---

### 3. Memory Ownership & Nullability
Types support chainable ownership and reference modifiers:

```vala
var node_type = ClassName.get ("", "Node").copy ();

// Weak & Nullable field: public weak Node? parent;
var parent_field = FieldSpec.builder (node_type.@weak ().nullable (), "parent")
    .visibility (Visibility.PUBLIC)
    .build ();

// Unowned return type: public unowned Node get_parent ()
var get_parent = MethodSpec.method_builder ("get_parent")
    .visibility (Visibility.PUBLIC)
    .returns (node_type.@unowned ())
    .add_statement ("return parent")
    .build ();

// Owned parameter: set_data (owned string data)
var set_data = MethodSpec.method_builder ("set_data")
    .visibility (Visibility.PUBLIC)
    .add_parameter (ParameterSpec.builder (TypeName.STRING.copy ().@owned (), "data").build ())
    .add_statement ("this.data = (owned) data")
    .build ();
```

---

### 4. GObject Properties
Generate auto-properties or properties with custom accessors and default values:

```vala
// Auto-property with default value
var age_prop = PropertySpec.builder (TypeName.INT, "age")
    .visibility (Visibility.PUBLIC)
    .auto ()
    .default_value ("32")
    .build ();

// Property with custom get/set bodies and private setter modifier
var get_body = CodeBlock.builder ().add_statement ("return _name").build ();
var set_body = CodeBlock.builder ().add_statement ("_name = value").build ();

var name_prop = PropertySpec.builder (TypeName.STRING, "name")
    .visibility (Visibility.PUBLIC)
    .set_visibility (Visibility.PRIVATE)
    .get_body (get_body)
    .set_body (set_body)
    .build ();
```

---

### 5. GObject Signals
Declare signals with parameter signatures and code attributes:

```vala
var activated_signal = SignalSpec.builder ("activated")
    .visibility (Visibility.PUBLIC)
    .add_parameter (ParameterSpec.builder (TypeName.INT, "value").build ())
    .add_attribute (AttributeSpec.builder ("Signal").add_argument ("action", "true").build ())
    .build ();
```

---

### 6. Constructors, Named Constructors & Destructors
Support for static construct blocks, GObject construct blocks, named constructors, and destructors:

```vala
var static_block = CodeBlock.builder ().add_statement ("stdout.printf (\"Static init\\n\")").build ();
var instance_block = CodeBlock.builder ().add_statement ("stdout.printf (\"Construct block\\n\")").build ();

var named_ctor = MethodSpec.named_constructor_builder ("from_file")
    .visibility (Visibility.PUBLIC)
    .add_parameter (ParameterSpec.builder (ClassName.get ("GLib", "File"), "file").build ())
    .add_statement ("this.path = file.get_path ()")
    .build ();

var dtor = MethodSpec.destructor_builder ()
    .add_statement ("stdout.printf (\"Cleaned up\\n\")")
    .build ();

var widget_class = TypeSpec.class_builder ("Widget")
    .visibility (Visibility.PUBLIC)
    .superclass (TypeName.OBJECT)
    .set_static_construct_block (static_block)
    .set_construct_block (instance_block)
    .add_method (named_ctor)
    .add_method (dtor)
    .build ();
```

---

### 7. Contract Programming (`requires` / `ensures`)
Add preconditions and postconditions directly to method builders:

```vala
var safe_divide = MethodSpec.method_builder ("safe_divide")
    .visibility (Visibility.PUBLIC)
    .returns (TypeName.DOUBLE)
    .add_parameter (ParameterSpec.builder (TypeName.DOUBLE, "numerator").build ())
    .add_parameter (ParameterSpec.builder (TypeName.DOUBLE, "denominator").build ())
    .add_requires ("denominator != 0.0")
    .add_ensures ("result >= 0.0")
    .add_statement ("return numerator / denominator")
    .build ();
```

---

### 8. Error Domains & Exception Handling (`throws`)
Define error domains and attach exception specifications to methods:

```vala
var file_error_domain = ErrorDomainSpec.builder ("FileError")
    .visibility (Visibility.PUBLIC)
    .add_error_code ("NOT_FOUND")
    .add_error_code ("PERMISSION_DENIED")
    .build ();

var read_file = MethodSpec.method_builder ("read_file")
    .visibility (Visibility.PUBLIC)
    .add_throws (ClassName.get ("", "FileError"))
    .add_statement ("throw new FileError.NOT_FOUND (\"File not found\")")
    .build ();
```

---

### 9. Generics & Parameterized Types
Declare type variables and generic type bounds:

```vala
var type_t = TypeVariableName.get ("T");

var container_class = TypeSpec.class_builder ("Container")
    .visibility (Visibility.PUBLIC)
    .superclass (TypeName.OBJECT)
    .add_type_variable (type_t)
    .build ();
```

---

### 10. Delegates
Define Vala callback delegates with custom parameter signatures and CCode attributes:

```vala
var callback_delegate = DelegateName.get ("Callback", TypeName.VOID)
    .add_parameter (ParameterSpec.builder (TypeName.INT, "id").build ())
    .add_attribute (AttributeSpec.builder ("CCode").add_argument ("has_target", "false").build ());
```

---

### 11. Parameter Directions (`out`, `ref`), Pointers & Multi-Dimensional Arrays

```vala
var void_ptr = TypeName.VOID.pointer_to ();
var matrix_type = new ArrayTypeName.of (TypeName.INT, 2); // int[,]

var process_data = MethodSpec.method_builder ("process_data")
    .visibility (Visibility.PUBLIC)
    .add_parameter (ParameterSpec.builder (TypeName.INT, "input").build ())
    .add_parameter (ParameterSpec.builder (TypeName.INT, "output")
        .direction (ParameterDirection.OUT)
        .build ())
    .add_parameter (ParameterSpec.builder (void_ptr, "raw_buffer").build ())
    .add_parameter (ParameterSpec.builder (matrix_type, "matrix").build ())
    .add_statement ("output = input * 2")
    .build ();
```

---

### 12. Keyword Safety & `NameAllocator`
`NameAllocator` guarantees valid Vala identifiers and automatically escapes Vala keywords using the `@` prefix (`@class`, `@signal`, `@weak`) or `_` prefix for literals/primitives (`_int`, `_true`):

```vala
var allocator = new NameAllocator ();
string kw_class = allocator.new_name ("class"); // -> "@class"
string kw_class2 = allocator.new_name ("class"); // -> "@class_2"
string kw_int = allocator.new_name ("int");    // -> "_int"
```

---

## Automatic Import & Namespace Resolution

`ValaWriter` automatically inspects all used `TypeName` references across types, methods, fields, and parameters, dynamically emitting sorted `using` directives at the top of the generated `.vala` file.

```vala
var vala_file = ValaFile.builder ()
    .add_type (my_class)
    .build ();

// Emission automatically resolves and emits: using GLib; etc.
```

---

## Custom Indentation Configuration

By default, `ValaWriter` formats output using tab indentation (`\t`). Custom space indentation (e.g. 2 spaces, 4 spaces) can be configured via `ValaFile.Builder`:

```vala
var vala_file = ValaFile.builder ()
    .indent ("  ") // Configures 2-space indentation
    .add_type (my_class)
    .build ();
```

---

## Build Library & Run Test Suite

```bash
meson setup build
meson test -C build --verbose
```

The test suite includes 34 (still barebones) unit tests verifying both output code format and AST compilation via `libvala`.

---

## License

Copyright 2026 ValaPoet Authors (check the AUTHORS file for details).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
