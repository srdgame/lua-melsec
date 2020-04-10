local class = require 'middleclass'

local parser = class('LUA_MELSEC_DATA_PARSER')

local data_fmts = {
	int8 = 'i1',
	uint8 = 'I1',
	int16 = 'i2',
	uint16 = 'I2',
	int32 = 'i4',
	uint32 = 'I4',
	float = 'f',
	double = 'd',
}

function parser:initialize(ascii)
	self._ascii = ascii
end

function parser:__call(fmt, data, index)
	assert(data and fmt, 'Data format')
	
	if fmt == 'bit' then
		return self:bit(data, index)
	end

	local bf = self._ascii and '>' or '<'

	local fmt = data_fmts[fmt]
	assert(fmt)

	return string.unpack(bf..fmt, data, index)
end

function parser:bit_ascii(data, index)
	assert(false, "not implemented")
	--- TODO:
end

--- 4 bits for one bit value
function parser:bit_bin(data, index)
	local lf = index % 2
	local new_index = (index // 2) + 1

	local val = string.unpack('I1', new_index)

	if lf then
		return (val >> 4) & 0xF
	else
		return val & 0xF
	end

	return index + 1
end

return parser
