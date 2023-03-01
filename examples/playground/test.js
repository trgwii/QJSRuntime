// zig build run -- examples/playground/test.js

for (const key of Object.keys(globalThis)) {
  print(key + ": " + typeof globalThis[key]);
}

const self = 'readFileSync("examples/playground/test.js");';

print("line 1" + self.split("\n")[0]);

print(48.52992877);

print(42);

import { foo } from "./foo.js";

foo();

nonexistant();
