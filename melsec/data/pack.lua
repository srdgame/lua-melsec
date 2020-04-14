local class = require 'middleclass'

local pack = class('LUA_MELSEC_DATA_PACK')

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

function pack:initialize(ascii)
	self._ascii = ascii
end

function pack:__call(fmt, val)
	assert(fmt, 'Format is missing')
	assert(val, 'Value is missing')
	
	if fmt == 'bit' then
		return self:bit_bin(val)
	end

	local bf = self._ascii and '>' or '<'

	if fmt == 'raw' or fmt == 'string' then
		assert(raw_len, 'String/raw length needed')
		return string.pack(bf..'c'..raw_len, val)
	end

	local dfmt = data_fmts[fmt]
	assert(dfmt, string.format('Format: %s is not supported', fmt))

	return string.pack(bf..dfmt, val)
end

function pack:bit_ascii(val)
	assert(false, "not implemented")
	--- TODO:
end

--- 4 bits for one bit value
function pack:bit_bin(val)
	return string.pack('I1', val and 0x1 or 0x0)
end

return pack
