from pathlib import Path

path = Path('/home/ubuntu/lua-license-panel/LuaLicense-Universal-Complete.lua')
text = path.read_text()
start = text.index('  -- BEGIN USER-SUPPLIED MAIN LUA')
end_marker = '  -- END USER-SUPPLIED MAIN LUA'
end = text.index(end_marker, start) + len(end_marker)
replacement = '''  -- ================================================================
  -- ============ MAIN LUA — PASTE FULL CODE HERE ===================
  -- ================================================================
  -- Paste the complete Main Lua exactly once between the two markers:
  -- BEGIN MAIN LUA
  -- [PASTE YOUR COMPLETE MAIN LUA HERE]
  -- END MAIN LUA
  --
  -- Do not split the Main Lua into another section, file, callback, or
  -- module. This whole block runs only after canonical validation succeeds.
  -- ================================================================
'''
path.write_text(text[:start] + replacement + text[end:])
print('SINGLE_MAIN_SECTION_REPLACED=PASS')
print('MAIN_SECTION_COUNT=', text.count('BEGIN USER-SUPPLIED MAIN LUA'))
