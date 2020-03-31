local class = require 'middleclass'

local base = class('LUA_MELSEC_FRAME_BASE')

function base:initialize(...)
end

function base:to_hex()
	assert(nil, "Not implemented!")
end

function base:from_hex(raw, index)
	assert(nil, "Not implemented!")
end

function base:__tostring()
	return "Lua-Melsec-Frame-Base"
end

return base
