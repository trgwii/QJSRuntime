import {
  stderr as _stderr,
  stdin as _stdin,
  stdout as _stdout,
  write,
} from "__core__";

export { exit, write };

export const stdin = _stdin();
export const stdout = _stdout();
export const stderr = _stderr();

const _C = {
  pre: "\x1b[",
  end: "m",
};

const C = {
  reset: _C.pre + 0 + _C.end,
  bold: _C.pre + 1 + _C.end,
  black: _C.pre + 30 + _C.end,
  red: _C.pre + 31 + _C.end,
  green: _C.pre + 32 + _C.end,
  yellow: _C.pre + 33 + _C.end,
  blue: _C.pre + 34 + _C.end,
  magenta: _C.pre + 35 + _C.end,
  cyan: _C.pre + 36 + _C.end,
  bright: {
    black: _C.pre + 90 + _C.end,
    red: _C.pre + 91 + _C.end,
    green: _C.pre + 92 + _C.end,
    yellow: _C.pre + 93 + _C.end,
    blue: _C.pre + 94 + _C.end,
    magenta: _C.pre + 95 + _C.end,
    cyan: _C.pre + 96 + _C.end,
  },
};

export function writeAll(fd, str) {
  let written = 0;
  while (written < str.length) {
    const result = write(fd, str.slice(written));
    if (result <= 0) throw new Error("write() returned " + String(result));
    written += result;
  }
}

const S = {
  undefined: C.black + "undefined" + C.reset,
  null: C.bold + "null" + C.reset,
  true: C.yellow + "true" + C.reset,
  false: C.yellow + "false" + C.reset,
};

export function inspect(x) {
  const t = typeof x;
  if (t === "undefined") return S.undefined;
  else if (t === "boolean") return x ? S.true : S.false;
  else if (t === "number") return C.yellow + x + C.reset;
  else if (t === "bigint") return C.yellow + x + "n" + C.reset;
  else if (t === "symbol") return C.green + String(x) + C.reset;
  else if (t === "string") return C.green + '"' + x + '"' + C.reset;
  else if (t === "function") {
    return C.cyan + "[Function: " + x.name + "]" + C.reset;
  } else if (t === "object") {
    if (!x) return S.null;
    else if (Array.isArray(x)) {
      let result = "[ ";
      result += inspect(x[0]);
      for (let i = 1; i < x.length; i++) {
        result += ", " + x[i];
      }
      return result + " ]";
    } else {
      let result = "{ ";
      let first = true;
      for (const key in x) {
        if (first) first = false;
        else result += ", ";
        result += key + ": " + inspect(x[key]);
      }
      return result + " }";
    }
  }
  throw new Error("Unknown type: " + t + "\n" + String(x));
}

export function log(...args) {
  for (let i = 0; i < args.length; i++) {
    writeAll(stdout, typeof args[i] === "string" ? args[i] : inspect(args[i]));
    if (i < args.length - 1) writeAll(stdout, " ");
  }
  writeAll(stdout, "\n");
}
