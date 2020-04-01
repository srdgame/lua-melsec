local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REQUEST_RANDOM_READ', base)


function read:initialize(ascii, words, dwords)
	base.initialize(ascii, types.CMD.RANDOM_READ, types.SUB_CMD.WORD)
	self._words = words or {}
	self._dwords = dwords or {}
end

function read:encode_sc(sc)
	if self:ascii() then
		local sc_name = sc.name
		if string.len(sc_name) == 1 then
			sc_name = sc_name .. '*'
		end
		assert(string.len(sc_name) == 2)
		return sc_name .. self:pack('I3', sc.index)
	else
		local code = types.SC[sc.name]
		assert(code, 'Incorrect Soft Component')
		return self:pack('I3I1', sc.index, code)
	end
end

function read:encode()
	local word_count = #self._words	
	local dword_count = #self._dwords

	local data = {}
	data[1] = self:pack('I1I1', word_count, dword_count)

	for _, v in ipairs(self._words) do
		data[#data + 1] = self:encode_sc(v)
	end

	for _, v in ipairs(self._dwords) do
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
