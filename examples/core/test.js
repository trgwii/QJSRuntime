import { stdout, writeSync } from "__core__";
import { encode } from "std";

const res = writeSync(stdout, encode("hello\n"));

writeSync(stdout, encode("write returned: " + String(res) + "\n"));
