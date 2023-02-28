pub const JSTags = enum(c_int) {
    // all tags with a reference count are negative
    JS_TAG_FIRST = -11, // first negative tag
    JS_TAG_BIG_DECIMAL = -11,
    JS_TAG_BIG_INT = -10,
    JS_TAG_BIG_FLOAT = -9,
    JS_TAG_SYMBOL = -8,
    JS_TAG_STRING = -7,
    JS_TAG_MODULE = -3, // used internally
    JS_TAG_FUNCTION_BYTECODE = -2, // used internally
    JS_TAG_OBJECT = -1,

    JS_TAG_INT = 0,
    JS_TAG_BOOL = 1,
    JS_TAG_NULL = 2,
    JS_TAG_UNDEFINED = 3,
    JS_TAG_UNINITIALIZED = 4,
    JS_TAG_CATCH_OFFSET = 5,
    JS_TAG_EXCEPTION = 6,
    JS_TAG_FLOAT64 = 7,
    // any larger tag is FLOAT64 if JS_NAN_BOXING
};

pub const EvalFlags = enum(c_int) {
    // Global code (default)
    JS_EVAL_TYPE_GLOBAL = (0 << 0),
    // Module code
    JS_EVAL_TYPE_MODULE = (1 << 0),
    // Direct call (internal use)
    JS_EVAL_TYPE_DIRECT = (2 << 0),
    // indirect call (internal use)
    JS_EVAL_TYPE_INDIRECT = (3 << 0),
    // duplicate
    // JS_EVAL_TYPE_MASK = (3 << 0),
    // Force 'strict' mode
    JS_EVAL_FLAG_STRICT = (1 << 3),
    // Force 'strip' mode
    JS_EVAL_FLAG_STRIP = (1 << 4),
    // Compile but do not run
    // The result is an object with a JS_TAG_FUNCTION_BYTECODE or JS_TAG_MODULE tag
    // It can be executed with JS_EvalFunction()
    JS_EVAL_FLAG_COMPILE_ONLY = (1 << 5),
    // Don't include the stack frames before this eval in the Error() backtraces
    JS_EVAL_FLAG_BACKTRACE_BARRIER = (1 << 6),
};
