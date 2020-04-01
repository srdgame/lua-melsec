local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local read = class('LUA_MELSEC_COMMAND_REQUEST_BLOCK_READ', base)


function read:initialize(ascii, word_or_bit, name, index, values)
	local sub_cmd = word_or_bit and types.SUB_CMD.WORD or types.SUB_CMD.BIT
	base.initialize(ascii, types.CMD.BLOCK_WRITE, sub_cmd)
	self._name = name
	self._index = index
	self._values = values
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
	local count = #self._values
	local pre = self:encode_sc({name=self._name, index = self._index, count = count})

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
		--TODO:
	end

	return pre..table.concat(data)
end

function read:decode(raw, index)
	assert(nil, 'Not suppported')
end

function read:__tostring()
	return base.__tostring(self)
end

return read
