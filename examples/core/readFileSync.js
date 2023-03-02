import { readFileSync } from "__core__";

console.log(readFileSync("README.md").split("\n")[0]);
