local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REQUEST_MULTI_READ', base)


function read:initialize(ascii, words, bits)
	base.initialize(ascii, types.CMD.MULTI_READ, types.SUB_CMD.WORD)
	self._words = words or {}
	self._bits = bits or {}
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
		local code = types.SC[sc.name]
		assert(code, 'Incorrect Soft Component')
		return self:pack('I3I1I2', sc.index, code, sc.count)
	end
end

function read:encode()
	local word_count = #self._words	
	local bit_count = #self._bits

	local data = {}
	data[1] = self:pack('I1I1', word_count, bit_count)

	for _, v in ipairs(self._words) do
		data[#data + 1] = self:encode_sc(v)
	end

	for _, v in ipairs(self._bits) do
		data[#data + 1] = self:encode_sc(v)
	end

	return table.concat(data)
end

function read:decode(raw, index)
	assert(nil, 'Not suppported')
end

function read:__tostring()
	return base.__tostring(self)
end

return read
