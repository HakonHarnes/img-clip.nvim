test: 
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua', sequential = true}"

luacheck: 
	luacheck lua/

stylua: 
	stylua --color always --check lua/
