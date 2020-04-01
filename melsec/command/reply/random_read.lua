local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REPLY_RANDOM_READ', base)


function read:initialize(ascii, values)
	base.initialize(ascii, types.CMD.RANDOM_READ, types.SUB_CMD.WORD)
	self._values = values
end

function read:encode()
	local data = {}

	for _, v in ipairs(self._values) do
		data[#data + 1] = self:pack('I2', v)
	end

	return table.concat(data)
end

function read:decode(raw, index)
	-- TODO: We have to access the request object to know how could we parse the values
	local values = {}
	while index < string.len(raw) do
		values[#values + 1], index = self:unpack('I2', raw, index)
	end
	self._values = values
	return index
end

function read:__tostring()
	return base.__tostring(self)
end

return read
