# modmark-robber
A proof of concept [modmark](https://github.com/modmark-org/modmark) package written in Zig, mainly just to show that it can be done.
First time using Zig so code is probably not optimal or pretty.
The packages provides transformations from a `[robber]` module to `html` and `latex` that converts the text to [rövarspråket](https://en.wikipedia.org/wiki/R%C3%B6varspr%C3%A5ket). The JSON sent from core cannot be above 10000 characters or the module will give an error.

To build a wasm module
```
zig build-exe -O ReleaseSmall -target wasm32-wasi src/main.zig
```