local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REQUEST_BLOCK_READ', base)


function read:initialize(ascii, word_or_bit, name, index, count)
	local sub_cmd = word_or_bit and types.SUB_CMD.WORD or types.SUB_CMD.BIT
	base.initialize(self, ascii, types.CMD.BLOCK_READ, sub_cmd)
	self._name = name
	self._index = index
	self._count = count
end

function read:encode_sc(sc)
	if self:ascii() then
		local sc_name = sc.name
		if string.len(sc_name) == 1 then
			sc_name = sc_name .. '*'
		end
		assert(string.len(sc_name) == 2)
		return sc_name .. self:pack('I3I2', sc.index, sc.count)
	else
		local sc_name = sc.name
		if string.sub(sc_name, -1) == '*' then
			sc_name = string.sub(sc_name, 1, -2)
		end
		local code = types.SC[sc_name]
		assert(code, 'Incorrect Soft Component:'..sc_name)
		return self:pack('I3I1I2', sc.index, code, sc.count)
	end
end

function read:encode()
	return self:encode_sc({name=self._name, index = self._index, count = self._count})
end

function read:decode(raw, index)
	assert(nil, 'Not suppported')
end

function read:__tostring()
	return base.__tostring(self)
end

return read
