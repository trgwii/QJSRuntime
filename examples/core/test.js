import { write } from "__core__";

const res = write(1, "hello\n");

write(1, "write returned: " + String(res) + "\n");
