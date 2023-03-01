import { log } from "../lib/std.js";

log(undefined, null, undefined);

log(true, false, "fart");

log(1234, 1234n);

log(Symbol("fart"));

function foo() {}

log(foo);

log([1, 2, true, "hello"]);

log({
  mega: "cool",
  giant: ["object", 42],
  symbol: Symbol("yes"),
});
