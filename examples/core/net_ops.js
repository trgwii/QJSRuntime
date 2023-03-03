import { closeSync, connectSync, readSync, writeSync } from "__core__";
import { decode, encode } from "std";

const buf = new Uint8Array(4096);

const fd = connectSync("google.com:80");

writeSync(fd, encode("GET / HTTP/1.1\n"));
writeSync(fd, encode("Host: google.com\n"));
writeSync(fd, encode("Connection: close\n"));
writeSync(fd, encode("\n"));

let read = readSync(fd, buf);
if (read < 0) throw new Error("read failed");
let total = read;
while (read > 0) {
  read = readSync(fd, buf.subarray(total));
  if (read < 0) throw new Error("read failed");
  total += read;
}

closeSync(fd);

console.log(
  decode(buf.subarray(0, total)).split("\n")
    .find((x) => x.startsWith("Date: ")),
);
