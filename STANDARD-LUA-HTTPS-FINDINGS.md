# Standard Lua HTTPS Findings

## Official library requirements

LuaSocket's official HTTP documentation states that `socket.http` must be loaded with `require("socket.http")`. Its generic request form supports method, headers, source, sink, timeout-related socket behavior, and returns a response result plus status/headers when successful; it requires the LuaSocket C core and Lua modules to be installed in the interpreter. LuaSocket's official overview describes a C core for TCP/UDP plus Lua modules and says the distribution is compatible with Lua 5.1 through 5.4.

LuaSec is a separate TLS binding for OpenSSL and lists LuaSocket as a dependency. Therefore HTTPS through the conventional Lua stack requires the runtime to expose compatible LuaSocket modules, LuaSec/OpenSSL support, native library loading, and a working certificate-verification configuration. A plain `https://` URL or the presence of Unreal Engine's native HTTP module does not automatically expose these capabilities to Lua.

## Comparison with the target runtime

The target Dynamic Execution runtime diagnostics already showed failed/unavailable imports for `socket.http`, Lua networking modules, Downloader, Http/WebRequest-style modules, and the inspected host tables. No verified Lua-callable function has been shown to accept a JSON POST and return an HTTP status plus response body. Consequently, standard LuaSocket/LuaSec can be evaluated only by a safe import-and-capability check in the user's own authorized runtime; adding a Lua wrapper alone cannot install the missing native modules or OpenSSL/TLS dependency.

## Security boundary

This evaluation is limited to documented standard libraries and non-invasive availability checks. It does not include hidden transport extraction, runtime interception, undocumented native calls, proprietary file harvesting, or server-validation bypass. The production loader remains fail-closed until a real, authorized request/response transport is available.

## Sources

1. LuaSocket HTTP reference: https://lunarmodules.github.io/luasocket/http.html
2. LuaSocket overview and compatibility: https://lunarmodules.github.io/luasocket/
3. LuaSec module metadata and dependencies: https://luarocks.org/modules/brunoos/luasec
