local class = require 'middleclass'
local base = require 'melsec.command.base'
local types = require 'melsec.command.types'
local basexx = require 'basexx'

local write = class('LUA_MELSEC_COMMAND_REQUEST_BLOCK_WRITE', base)


function write:initialize(ascii, word_or_bit, name, index, values, raw_values)
	local sub_cmd = word_or_bit and types.SUB_CMD.WORD or types.SUB_CMD.BIT
	base.initialize(self, ascii, types.CMD.BLOCK_WRITE, sub_cmd)
	self._name = name
	self._index = index
	self._values = values
	self._raw_values = raw_values
end

function write:encode_sc(sc)
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

function write:encode()
	if self._raw_values then
		return self:encode_raw()
	end

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
		for _, v in ipairs(self._values) do
			data[#data + 1] = self:pack('I2', v)
		end
	end

	return pre..table.concat(data)
end

function write:encode_raw()
	local count = self._values.count
	local data = self._values.data

	local pre = self:encode_sc({name=self._name, index = self._index, count = count})

	if self:sub_cmd() == types.SUB_CMD.BIT then
		--- TODO:
	else
		--- TODO:
	end

	return pre..data
end

function write:decode(raw, index)
	assert(nil, 'Not suppported')
end

function write:__tostring()
	return base.__tostring(self)
end

return write
