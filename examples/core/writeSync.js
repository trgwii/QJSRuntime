import { stdout, writeSync } from "__core__";

// console.log("foo");
writeSync(stdout, new Uint8Array([97, 98, 99, 10]));
