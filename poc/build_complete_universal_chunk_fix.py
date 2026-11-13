from pathlib import Path

project = Path('/home/ubuntu/lua-license-panel')
upload = Path('/home/ubuntu/upload/BRPlayerCharacterBase.lua')
base = project / 'LuaLicense-Universal-Complete.lua'
out = project / 'LuaLicense-Universal-Complete-ChunkFix.lua'

uploaded = upload.read_text(encoding='utf-8')
base_text = base.read_text(encoding='utf-8')

begin = '-- BEGIN USER-SUPPLIED MAIN LUA\n'
end = '\n  -- END USER-SUPPLIED MAIN LUA'
start = uploaded.index(begin) + len(begin)
stop = uploaded.index(end, start)
main_source = uploaded[start:stop]
# The uploaded integration attempt placed this Universal wrapper call after
# the user's top-level module return. It is not part of the user's Main Lua.
wrapper_line = '  fetch_active_announcement(validated_key)'
if main_source.rstrip().endswith(wrapper_line):
    main_source = main_source.rstrip()[:-len(wrapper_line)].rstrip() + '\n'

# Keep the uploaded Main Lua as a literal source chunk. This preserves its
# return statement and top-level module contract without placing wrapper code
# after that return inside the same Lua block.
delimiter = '===='
while f']{delimiter}]' in main_source:
    delimiter += '='
open_token = f'[{delimiter}[\n'
close_token = f'\n]{delimiter}]'
main_literal = open_token + main_source + close_token

old_start = base_text.index('local function run_authorized_main_once(LICENSE_SESSION, validated_key)')
old_end = base_text.index('\n\n-- The existing canonical validator reaches this dispatcher only after its', old_start)
new_function = f'''local function run_authorized_main_once(LICENSE_SESSION, validated_key)\n  -- The complete Main Lua is kept as one source chunk. Its original\n  -- top-level return/module contract is therefore preserved.\n  local MAIN_LUA_SOURCE = {main_literal}\n  local compiler = loadstring or load\n  if type(compiler) ~= "function" then\n    stop("Lua chunk compiler unavailable")\n  end\n  local ok_compile, main_chunk, compile_error = pcall(function()\n    if compiler == load then\n      return compiler(MAIN_LUA_SOURCE, "<USER_MAIN_LUA>", "t", _ENV)\n    end\n    return compiler(MAIN_LUA_SOURCE, "<USER_MAIN_LUA>")\n  end)\n  if not ok_compile or type(main_chunk) ~= "function" then\n    stop("Main Lua compilation failed: " .. tostring(compile_error or main_chunk))\n  end\n  local ok_run, module_result = pcall(main_chunk)\n  if not ok_run then\n    stop("Main Lua execution failed: " .. tostring(module_result))\n  end\n  -- This wrapper call is intentionally after the chunk returns, so it never\n  -- appears after the user's top-level return inside the same Lua block.\n  fetch_active_announcement(validated_key)\n  return module_result or LICENSE_SESSION\nend'''
fixed = base_text[:old_start] + new_function + base_text[old_end:]
out.write_text(fixed, encoding='utf-8')

# Write a machine-readable comparison artifact without copying secrets.
meta = project / 'poc' / 'complete_universal_chunk_fix_metadata.txt'
meta.write_text(
    f'MAIN_SOURCE_LINES={main_source.count(chr(10)) + 1}\n'
    f'MAIN_SOURCE_SHA256={__import__("hashlib").sha256(main_source.encode()).hexdigest()}\n'
    f'OUTPUT={out}\n'
    'INTEGRATION_ONLY_FIX=true\n'
    'PROTECTED_FLOW_REWRITTEN=false\n',
    encoding='utf-8',
)
print(out)
print(meta)
print('main_lines', main_source.count(chr(10)) + 1)
print('main_sha256', __import__('hashlib').sha256(main_source.encode()).hexdigest())

if __name__ == '__main__':
    pass
