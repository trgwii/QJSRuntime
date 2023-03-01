import { exit, log } from "../../lib/std.js";

log("Hello");

exit(0);

// Never called
log("World");
