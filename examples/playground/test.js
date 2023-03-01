// zig build run -- examples/playground/test.js
import { log } from "../../lib/std.js";

for (const key of Object.keys(globalThis)) {
  log(key + ": " + typeof globalThis[key]);
}

const self = 'readFileSync("examples/playground/test.js");';

log("line 1" + self.split("\n")[0]);

log(48.52992877);

log(42);

import { foo } from "./foo.js";

foo();

nonexistant();
