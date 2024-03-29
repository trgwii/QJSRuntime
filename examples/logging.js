import { log } from "../lib/std.js";

log(undefined, null, undefined);

log(true, false, "foo");

log(1234, 1234n);

log(Symbol("foo"));

function foo() {}

async function bar() {
	await undefined;
	log("async is cool!");
}

bar();

log(foo);

log([1, 2, true, "hello"]);

log({
	mega: "cool",
	giant: ["object", 42],
	symbol: Symbol("yes"),
});
