# QJSRuntime

Experimental JS runtime based on QuickJS

## Run an example

```sh
zig build run -- examples/logging.js
```

## Run all examples

```sh
zig run scripts/examples.zig
```

## Release build

```sh
zig build -Doptimize=ReleaseFast
```
