from pathlib import Path

source = Path('/home/ubuntu/upload/BRPlayerCharacterBase.lua').read_text(encoding='utf-8')
start = source.index('-- BEGIN USER-SUPPLIED MAIN LUA\n') + len('-- BEGIN USER-SUPPLIED MAIN LUA\n')
stop = source.index('\n  -- END USER-SUPPLIED MAIN LUA', start)
main = source[start:stop]
Path('/home/ubuntu/lua-license-panel/poc/uploaded_main_extracted.lua').write_text(main, encoding='utf-8')
print('main_lines=', main.count('\n') + 1)
print('main_has_wrapper_fetch=', 'fetch_active_announcement(validated_key)' in main)
print('main_has_top_level_return=', 'return require("combine_class").DeclareFeature' in main)
print('main_first_line=', repr(main.splitlines()[0]))
print('main_last_line=', repr(main.splitlines()[-1]))
print('main_extract=/home/ubuntu/lua-license-panel/poc/uploaded_main_extracted.lua')
