import { stdout, writeSync } from "__core__";

// console.log("fart");
writeSync(stdout, new Uint8Array([97, 98, 99, 10]));
