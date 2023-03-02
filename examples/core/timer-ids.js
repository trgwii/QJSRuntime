import { setTimeout } from "__core__";

console.log(
  "added timer " + setTimeout(() => {
    console.log("first (300)");
  }, 300),
);
console.log(
  "added timer " + setTimeout(() => {
    console.log("second (200)");
  }, 200),
);
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
