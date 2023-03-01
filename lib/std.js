import { write } from "__core__";

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

/** @type {(fd: number, str: string) => void} */
function writeAll(fd, str) {
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

function logNoNewline(x) {
  const t = typeof x;
  if (t === "undefined") writeAll(1, S.undefined);
  else if (t === "boolean") writeAll(1, x ? S.true : S.false);
  else if (t === "number") writeAll(1, C.yellow + x + C.reset);
  else if (t === "bigint") writeAll(1, C.yellow + x + "n" + C.reset);
  else if (t === "symbol") writeAll(1, C.green + String(x) + C.reset);
  else if (t === "string") writeAll(1, C.green + '"' + x + '"' + C.reset);
  else if (t === "function") {
    writeAll(1, C.cyan + "[Function: " + x.name + "]" + C.reset);
  } else if (t === "object") {
    if (!x) writeAll(1, S.null);
    else if (Array.isArray(x)) {
      writeAll(1, "[ ");
      logNoNewline(x[0]);
      for (let i = 1; i < x.length; i++) {
        writeAll(1, ", ");
        logNoNewline(x[i]);
      }
      writeAll(1, " ]");
    } else {
      writeAll(1, "{ ");
      let first = true;
      for (const key in x) {
        if (first) first = false;
        else writeAll(1, ", ");
        writeAll(1, key + ": ");
        logNoNewline(x[key]);
      }
      writeAll(1, " }");
    }
  }
}

export function log(...args) {
  for (let i = 0; i < args.length; i++) {
    logNoNewline(args[i]);
    if (i < args.length - 1) write(1, " ");
  }
  write(1, "\n");
}
