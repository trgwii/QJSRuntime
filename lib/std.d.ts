// core
declare function exit(code: number): never;
declare function write(fd: number, str: string): number;
declare const stdin: number;
declare const stdout: number;
declare const stderr: number;

// std
declare function writeAll(fd: number, str: string): void;
declare function inspect(x: any): string;
declare function log(...args: any[]): void;
