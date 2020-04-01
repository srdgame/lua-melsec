local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REPLY_BLOCK_READ', base)


function read:initialize(ascii, word_or_bit, values)
	local sub_cmd = word_or_bit and types.SUB_CMD.WORD or types.SUB_CMD.BIT
	base.initialize(ascii, types.CMD.BLOCK_READ, sub_cmd)
	self._values = values
end

local function bit_value(bit)
	if bit == true then
		return 1
	end
	if bit == 1 then
		return 1
	end
	return 0
end

function read:encode()
	local data = {}

	if self:sub_cmd() == types.SUB_CMD.BIT then
		if #self._values % 2 == 1 then
			table.insert(self._values, 0)
		end

		for i = 1, #self._values, 2 do
			local v = bit_value(self._values[i]) << 4 + bit_value(self._values[i + 1])
			data[#data + 1] = self:pack('I1', v)
		end
	else
		for _, v in ipairs(self._values) do
			data[#data + 1] = self:pack('I2', v)
		end
	end

	return table.concat(data)
end

local function bit_decode(val)
	return val >> 4, val & 0x0F
end

function read:decode(raw, index)
	local values = {}

	if self:sub_cmd() == types.SUB_CMD.BIT then
		local val = nil
		while index < string.len(raw) do
			val, index = self:unpack('I1', raw, index)
			local b1, b2 = bit_decode(val)
			values[#values + 1] = b1
			values[#values + 1] = b2
		end
	else
		while index < string.len(raw) do
			values[#values + 1], index = self:unpack('I2', raw, index)
		end
	end

	self._values = values

	return index
end

function read:__tostring()
	return base.__tostring(self)
end

return read
