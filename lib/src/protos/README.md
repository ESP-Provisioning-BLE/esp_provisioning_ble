# Protobuf files for implementing protocol communication packets

Protocomm uses Google Protobuf for language, transport and architecture agnostic protocol communication. These proto files define the protocomm packet structure, separated across multiple files:
* contants.proto - Defines the "Status" structure for conveying the success or failure of a single protocomm transaction
* sec0.proto - Defines the Security0 Command and Response packet structures
* sec1.proto - Defines the Security1 Command and Response packet structures
* session.proto - Defines the protocomm transacion packets for session establishment which internally has a Security packet as payload

Note : These proto files are not automatically compiled during the build process.

# Compilation

Compilation requires protoc (Protobuf Compiler) and protoc-c (Protobuf C Compiler) installed. Since the generated files are to remain the same, as long as the proto files are not modified, therefore the generated files are already available under `components/protocomm/proto-c` and `components/protocomm/python` directories, and thus running cmake / make (and installing the Protobuf compilers) is optional.

If using `cmake` follow the below steps. If using `make`, jump to Step 2 directly.

## Step 1 (Only for cmake)

When using cmake, first create a build directory and call cmake from inside:

```
mkdir build
cd build
cmake ..
```

## Step 2

Simply run `make` to generate the respective C and Python files. The newly created files will overwrite those under `components/protocomm/proto-c` and `components/protocomm/python`

# Dart bindings (esp_provisioning_ble)

The sections above are copied from ESP-IDF. In this package, the Dart bindings used by the library live in `generated/` and are committed to the repository, so they only need to be regenerated when a `.proto` file changes or when the `protobuf` dependency moves to a new major version.

The generated code must match the `protobuf` constraint in `pubspec.yaml`, so use these pinned versions:

* `protoc` 35.1 (any recent `protoc` gives the same output for these files)
* `protoc_plugin` 21.0.2 (generates code for `protobuf` ^3.0.0; it reproduces the committed bindings byte for byte, while 21.1.x adds doc comments and named-argument constructors)

Install the plugin and make sure `protoc-gen-dart` is on the `PATH`:

```
dart pub global activate protoc_plugin 21.0.2
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Then, after running `flutter pub get` in the package root (so that `dart format` picks up the package's language version), regenerate and format the bindings from this directory:

```
make dart_proto
```

This writes every `*.pb.dart`, `*.pbenum.dart` and `*.pbjson.dart` file into `generated/`, deletes the empty `*.pbserver.dart` files that this plugin version also emits (none of these `.proto` files defines a service), and runs `dart format` on them, which the CI format check requires. Review the result together with `test/src/protos_wire_format_test.dart`, which pins the bytes exchanged with the device.
