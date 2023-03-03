import { closeSync, openSync, readSync } from "__core__";
import { decode } from "std";

const buf = new Uint8Array(4096);

const fd = openSync("README.md");

let read = readSync(fd, buf);
if (read < 0) throw new Error("read failed");
let total = read;
while (read > 0) {
  read = readSync(fd, buf.subarray(total));
  if (read < 0) throw new Error("read failed");
  total += read;
}

closeSync(fd);

console.log(decode(buf.subarray(0, total)).split("\n")[2]);
