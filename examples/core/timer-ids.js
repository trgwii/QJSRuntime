import { clearTimeout, setTimeout } from "__core__";

console.log(
  "added timer " + setTimeout(() => {
    console.log("first (300)");
  }, 300),
);
const second = setTimeout(() => {
  console.log("second (200)");
}, 200);
console.log("added timer " + second);
console.log(
  "added timer " + setTimeout(() => {
    console.log("third (100)");
  }, 100),
);
console.log(
  "added timer " + setTimeout(() => {
    console.log("fourth (0)");
  }, 0),
);
clearTimeout(second);
